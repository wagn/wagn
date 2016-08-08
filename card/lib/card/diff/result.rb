class Card
  class Diff
    class Result
      attr_accessor :complete, :summary, :dels_cnt, :adds_cnt
      def initialize summary_opts=nil
        @dels_cnt = 0
        @adds_cnt = 0
        @complete = ""
        @summary = Summary.new summary_opts
      end

      def summary
        @summary.rendered
      end

      def write_added_chunk text
        @adds_cnt += 1
        @complete << Card::Diff.render_added_chunk(text)
        @summary.add text
      end

      def write_deleted_chunk text
        @dels_cnt += 1
        @complete << Card::Diff.render_deleted_chunk(text)
        @summary.delete text
      end

      def write_unchanged_chunk text
        @complete << text
        @summary.omit
      end

      def write_excluded_chunk text
        @complete << text
      end

      class Summary
        def initialize opts
          opts ||= {}
          @remaining_chars = opts[:length] || 50
          @joint = opts[:joint] || "..."

          @summary = nil
          @chunks = []
        end

        def rendered
          @summary ||=
            begin
              truncate_overlap
              @chunks.map do |chunk|
                render_chunk chunk[:action], chunk[:text]
              end.join
            end
        end

        def add text
          add_chunk text, :added
        end

        def delete text
          add_chunk text, :deleted
        end

        def omit
          if @chunks.empty? || @chunks.last[:action] != :ellipsis
            add_chunk @joint, :ellipsis
          end
        end

        private

        def add_chunk text, action
          if @remaining_chars > 0
            @chunks << { action: action, text: text }
            @remaining_chars -= text.size
          end
        end

        def render_chunk action, text
          case action
          when "+", :added then Card::Diff.render_added_chunk text
          when "-", :deleted then Card::Diff.render_deleted_chunk text
          else text
          end
        end

        def truncate_overlap
          if @remaining_chars < 0
            if @chunks.last[:action] == :ellipsis
              @chunks.pop
              @remaining_chars += @joint.size
            end

            index = @chunks.size - 1
            while @remaining_chars < @joint.size && index >= 0
              if @remaining_chars + @chunks[index][:text].size == @joint.size
                replace_with_joint index
                break
              elsif @remaining_chars + @chunks[index][:text].size > @joint.size
                cut_with_joint index
                break
              else
                @remaining_chars += @chunks[index][:text].size
                @chunks.delete_at(index)
              end
              index -= 1
            end
          end
        end

        def cut_with_joint index
          @chunks[index][:text] =
            @chunks[index][:text][0..(@remaining_chars - @joint.size - 1)]
          @chunks[index][:text] += @joint
        end

        def replace_with_joint index
          @chunks.pop
          if index - 1 >= 0
            if @chunks[index - 1][:action] == :added
              @chunks << { action: :ellipsis, text: @joint }
            elsif @chunks[index - 1][:action] == :deleted
              @chunks << { action: :added, text: @joint }
            end
          end
        end
      end
    end
  end
end
