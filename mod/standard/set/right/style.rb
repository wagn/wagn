require 'sass'
include Machine

store_machine_output :filetype => "css"

def chunk_list  #turn off autodetection of uri's 
                #TODO with the new format pattern this should be handled in the js format
    :inclusion_only
end

