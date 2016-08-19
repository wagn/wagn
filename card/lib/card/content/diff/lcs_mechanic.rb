class Card
  class Content
    class Diff
      class LCS
        # support methods for LCS::Processor
        module ProcessorMechanic
          private

          def interpret_action prev_action, word
            if (prev_action == word.action) ||
               (prev_action == "-" && word.action == "!") ||
               (prev_action == "!" && word.action == "+")
              handle_action word.action
            else
              write_all
            end
          end

          def handle_action action
            case action
            when "-" then del_old_excludees
            when "+" then add_new_excludees
            when "!" then
              del_old_excludees
              add_new_excludees
            else
              write_excludees
            end
          end

          def write_all
            write_dels
            write_adds
            write_excludees
          end

          def write_unchanged text
            @result.write_unchanged_chunk text
          end

          def write_dels
            return if @dels.empty?
            @result.write_deleted_chunk @dels.join
            @dels = []
          end

          def write_adds
            return if @adds.empty?
            @result.write_added_chunk @adds.join
            @adds = []
          end

          def write_excludees
            while (ex = @excludees[:new].next)
              @result.write_excluded_chunk ex[:element]
            end
          end

          def del_old_excludees
            while (ex = @excludees[:old].next)
              if ex[:type] == :disjunction
                @dels << ex[:element]
              else
                write_dels
                @result.write_excluded_chunk ex[:element]
              end
            end
          end

          def add_new_excludees
            while (ex = @excludees[:new].next)
              if ex[:type] == :disjunction
                @adds << ex[:element]
              else
                write_adds
                @result.complete << ex[:element]
              end
            end
          end

          def process_element old_element, new_element, action
            case action
            when "-" then minus old_element
            when "+" then plus new_element
            when "!"
              minus old_element
              plus new_element
            else
              write_unchanged new_element
              @excludees[:new].word_step
            end
          end

          def plus new_element
            @adds << new_element
            @excludees[:new].word_step
          end

          def minus old_element
            @dels << old_element
            @excludees[:old].word_step
          end
        end
      end
    end
  end
end