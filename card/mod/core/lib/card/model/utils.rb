# class Card
#   module Model
    module Card::Model::Utils
      def empty_trash
        Card.delete_trashed_files
        Card.where(trash: true).delete_all
        Card::Action.delete_cardless
        Card::Reference.unmap_if_referee_missing
        Card::Reference.delete_if_referer_missing
      end

      # deletes any file not associated with a real card.
      def delete_trashed_files
        trashed_card_ids = all_trashed_card_ids
        file_ids = all_file_ids
        dir = Cardio.paths["files"].existent.first
        file_ids.each do |file_id|
          next unless trashed_card_ids.member?(file_id)
          if Card.exists?(file_id) # double check!
            raise Card::Error, "Narrowly averted deleting current file"
          end
          FileUtils.rm_rf "#{dir}/#{file_id}", secure: true
        end
      end

      def all_file_ids
        dir = Card.paths["files"].existent.first
        Dir.entries(dir)[2..-1].map(&:to_i)
      end

      def all_trashed_card_ids
        trashed_card_sql = %( select id from cards where trash is true )
        sql_results = Card.connection.select_all(trashed_card_sql)
        sql_results.map(&:values).flatten.map(&:to_i)
      end

      def merge_list attribs, opts={}
        unmerged = []
        attribs.each do |row|
          result = begin
            merge row["name"], row, opts
          end
          unmerged.push row unless result == true
        end

        if unmerged.empty?
          Rails.logger.info "successfully merged all!"
        else
          unmerged_json = JSON.pretty_generate unmerged
          report_unmerged_json unmerged_json, opts[:output_file]
        end
        unmerged
      end

      def report_unmerged_json unmerged_json, output_file
        if output_file
          ::File.open output_file, "w" do |f|
            f.write unmerged_json
          end
        else
          Rails.logger.info "failed to merge:\n\n#{unmerged_json}"
        end
      end

      def merge name, attribs={}, opts={}
        puts "merging #{name}"
        card = fetch name, new: {}
        [:image, :file].each do |attach|
          next unless attribs[attach] && attribs[attach].is_a?(String)
          attribs[attach] = ::File.open(attribs[attach])
        end
        if opts[:pristine] && !card.pristine?
          false
        else
          card.update_attributes! attribs
        end
      end
    end
#   end
# end
