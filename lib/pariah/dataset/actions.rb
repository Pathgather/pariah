# frozen_string_literal: true

require "set"

module Pariah
  class Dataset
    module Actions
      def refresh
        execute_request(
          method: :post,
          path: [indices_as_string, '_refresh'],
        )
      end

      def create_index
        unless schema = @opts[:index_schema]
          raise Error, "No index_schema specified!"
        end

        # Ensure that dynamic field mapping is explicitly disallowed.
        settings = schema[:settings] ||= {}
        settings['index.mapper.dynamic'] = false

        execute_request(
          method: :put,
          path: single_index,
          body: schema,
          allowed_codes: [200, 400], # Index may already exist.
        )
      end

      def rewrite_index
        target_alias = single_index

        # Is this already an alias for something else?
        aliases =
          execute_request(
            method: :get,
            path: [target_alias, '_aliases'],
            allowed_codes: [200, 404],
          )

        preexisting_indexes =
          if aliases[:status] == 404
            []
          else
            aliases.keys.map(&:to_s)
          end

        # Actual index names are the alias name plus the number of nanoseconds
        # since epoch. This helps avoid collisions, which could happen in specs.
        nanoseconds_since_epoch = (Time.now.to_f * 100_000_000).round
        new_index_name = "#{target_alias}-#{nanoseconds_since_epoch}"
        new_index_ds   = self[new_index_name]

        new_index_ds.create_index
        yield(new_index_ds)

        actions = []

        preexisting_indexes.each do |index|
          if index == target_alias
            # The target alias is the name of an actual index, so we can't do
            # zero-downtime, but do the best we can.
            drop_index
          else
            actions.push(remove: {index: index, alias: target_alias})
          end
        end

        actions.push(add: {index: new_index_name, alias: target_alias})

        execute_request(
          method: :post,
          path: '_aliases',
          body: {actions: actions}
        )

        preexisting_indexes.each do |index|
          if index == target_alias
            next # Already dropped.
          else
            self[index].drop_index?
          end
        end

        new_index_ds.refresh
        true
      rescue
        self[new_index_name].drop_index?
        raise
      end

      def drop_index(allowed_errors: [])
        execute_request(
          method: :delete,
          path: indices_as_string,
          allowed_errors: allowed_errors,
        )
      end

      def drop_index?
        drop_index(
          allowed_errors: [
            "no such index",
            /Cannot delete indices that are being snapshotted/,
          ]
        )
      end

      def drop_orphaned_indexes(filter: nil)
        indexes =
          execute_request(method: :get, path: "/_cat/indices?format=json").
          map{|h| h[:index]}

        indexes_with_aliases =
          execute_request(method: :get, path: "/_cat/aliases?format=json").
          map{|h| h[:index]}.
          to_set

        indexes = indexes.grep(filter) if filter

        indexes.
          reject{|index| indexes_with_aliases.include?(index)}.
          each{|i| self[i].drop_index}
      end

      def each(&block)
        with_loaded_results { |ds| ds.all.each(&block) }
      end

      def all
        with_loaded_results do |ds|
          ds.results[:hits][:hits].map do |hit|
            hit[:fields] || hit[:_source]
          end
        end
      end

      def delete
        execute_request(
          method: :post,
          path: [indices_as_string, types_as_string, '_delete_by_query'],
          body: to_query,
        )
      end

      def aggregations
        with_loaded_results { |ds| ds.results[:aggregations] }
      end

      def count
        with_loaded_results { |ds| ds.results[:hits][:total] }
      end

      def load
        clone.tap(&:load!)
      end

      def upsert(records)
        unless records.is_a?(Array)
          records = [records]
        end

        records = records.compact
        return if records.empty?

        current_type = nil
        rows = []

        records.each do |record|
          metadata = {}

          if id = record.delete(:_id) || record[:id]
            metadata[:_id] = id
          end

          if parent = record.delete(:_parent)
            metadata[:_parent] = parent
          end

          if i = record.delete(:_index)
            metadata[:_index] = i
          end

          if t = record.delete(:_type)
            metadata[:_type] = t
          elsif i
            # We're sending the record to a different index, so we need to
            # make sure we specify the type.
            current_type ||= single_type
            metadata[:_type] = current_type
          end

          rows << JSON.dump(index: metadata)
          rows << JSON.dump(record)
        end

        body = rows.join("\n") << "\n"

        r =
          execute_request(
            method: :post,
            path: [single_index, single_type, '_bulk'],
            body: body,
          )

        if r[:errors]
          raise Error, "errors raised on upsert: #{r.inspect}"
        end

        r
      end

      protected

      def load!
        @results =
          execute_request(
            method: :post,
            path: [indices_as_string, types_as_string, '_search'],
            body: to_query,
          )
      end

      private

      def with_loaded_results
        yield(results ? self : load)
      end
    end
  end
end
