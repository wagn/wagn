class Card
  class Diff

    class WordProcessor
      attr_reader :result, :summary, :dels_cnt, :adds_cnt
      def initialize old_words, new_words, old_excludees, new_excludees
        @adds = []
        @dels = []
        @words = {
          old: old_words,
          new: new_words
        }
        @excludees = {
          old: ExcludeeIterator.new(old_excludees),
          new: ExcludeeIterator.new(new_excludees)
        }
      end

      def run result
        @result = result
        prev_action = nil
        ::Diff::LCS.traverse_balanced(@words[:old], @words[:new]) do |word|
          if prev_action
            if prev_action != word.action &&
              !(prev_action == '-' && word.action == '!') &&
              !(prev_action == '!' && word.action == '+')

              # delete and/or add section stops here; write changes to result
              write_dels
              write_adds

              # new neutral section starts
              # we can just write excludees to result
              write_excludees

            else # current word belongs to edit of previous word
              case word.action
              when '-'
                del_old_excludees
              when '+'
                add_new_excludees
              when '!'
                del_old_excludees
                add_new_excludees
              else
                write_excludees
              end
            end
          else
            write_excludees
          end

          process_word word
          prev_action = word.action
        end
        write_dels
        write_adds
        write_excludees

        @result
      end

      private

      def write_unchanged text
        @result.write_unchanged_chunk text
      end

      def write_dels
        unless @dels.empty?
          @result.write_deleted_chunk @dels.join
          @dels = []
        end
      end

      def write_adds
        unless @adds.empty?
          @result.write_added_chunk @add.join
          @adds = []
        end
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

      def process_word word
        process_element word.old_element, word.new_element, word.action
      end

      def process_element old_element, new_element, action
        case action
        when '-'
          minus old_element
        when '+'
          plus new_element
        when '!'
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

    class ExcludeeIterator
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
    end
  end
end