class Card
  class Content
    class Diff
      class LCS
        # Compares two lists of chunks and generates a diff
        class Processor
          def initialize old_words, new_words, old_excludees, new_excludees
            @adds = []
            @dels = []
            @words = { old: old_words, new: new_words }
            @excludees =
              ExcludeeIterator.old_and_new old_excludees, new_excludees
          end

          def run result
            @result = result
            prev_action = nil
            ::Diff::LCS.traverse_balanced(@words[:old], @words[:new]) do |word|
              if prev_action
                interpret_action prev_action, word
              else
                write_excludees
              end
              process_element word.old_element, word.new_element, word.action
              prev_action = word.action
            end
            write_all
            @result
          end

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
            @excludees[:old].scan_and_record(@dels) do |element|
              write_dels
              @result.write_excluded_chunk element
            end
          end

          def add_new_excludees
            @excludees[:new].scan_and_record(@adds) do |element|
              write_adds
              @result.complete << element
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

        # support class for LCS::Processor
        class ExcludeeIterator
          def self.old_and_new old_excludees, new_excludees
            {
              old: new(old_excludees),
              new: new(new_excludees)
            }
          end

          def initialize list
            @list = list
            @index = 0
            @chunk_index = 0
          end

          def word_step
            @chunk_index += 1
          end

          def next
            if @index < @list.size &&
               @list[@index][:chunk_index] == @chunk_index
              res = @list[@index]
              @index += 1
              @chunk_index += 1
              res
            end
          end

          def scan_and_record record_array
            while (ex = self.next)
              if ex[:type] == :disjunction
                record_array << ex[:element]
              else
                yield ex[:element]
              end
            end
          end
        end
      end
    end
  end
end
