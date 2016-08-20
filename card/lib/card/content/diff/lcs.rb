require_dependency "card/content/diff/processor"

class Card
  class Content
    class Diff
      # Use LCS algorithm to create a Diff::Result
      class LCS
        def initialize opts
          # regex; remove matches completely from diff
          @reject_pattern = opts[:reject]
          # regex; put matches back to the result after diff
          @exclude_pattern = opts[:exclude]

          @preprocess   = opts[:preprocess]  # block; called with every word
          @postprocess  = opts[:postprocess] # block; called with complete diff

          @splitters = %w(<[^>]+> \[\[[^\]]+\]\] \{\{[^}]+\}\} \s+)
          @disjunction_pattern = /^\s/
        end

        def run old_text, new_text, result
          @result = result
          compare old_text, new_text
          @result.complete = postprocess @result.complete
        end

        private

        def compare old_text, new_text
          if old_text
            old_words, old_ex = separate_comparables_from_excludees old_text
            new_words, new_ex = separate_comparables_from_excludees new_text
            processor = Processor.new old_words, new_words, old_ex, new_ex
            processor.run @result
          else
            list = split_and_preprocess(new_text)
            if @exclude_pattern
              list = list.reject { |word| word.match @exclude_pattern }
            end
            # CAUTION: postproces and added_chunk changed order
            # and no longer postprocess for summary
            @result.write_added_chunk list.join
          end
        end

        def separate_comparables_from_excludees text
          # return two arrays, one with all words, one with pairs
          # (index in word list, html_tag)
          list = split_and_preprocess text
          if @exclude_pattern
            check_exclude_and_disjunction_pattern list
          else
            [list, []]
          end
        end

        def check_exclude_and_disjunction_pattern list
          list.each_with_index.each_with_object([[], []]) do |pair, res|
            element, index = pair
            if element.match @disjunction_pattern
              res[1] << { chunk_index: index, element: element,
                          type: :disjunction }
            elsif element.match @exclude_pattern
              res[1] << { chunk_index: index, element: element, type:
                :excludee }
            else
              res[0] << element
            end
          end
        end

        def split_and_preprocess text
          splitted = split_to_list_of_words(text).select do |s|
            !s.empty? && (!@reject_pattern || !s.match(@reject_pattern))
          end
          @preprocess ? splitted.map { |s| @preprocess.call(s) } : splitted
        end

        def split_to_list_of_words text
          split_regex = /(#{@splitters.join '|'})/
          text.split(split_regex)
        end

        def preprocess text
          @preprocess ? @preprocess.call(text) : text
        end

        def postprocess text
          @postprocess ? @postprocess.call(text) : text
        end
      end
    end
  end
end
