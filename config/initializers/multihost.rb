if Wagn::Conf[:multihost] and wagn_name=ENV['WAGN']
#  Rails.logger.info("------- Multihost.  Wagn Name = #{wagn_name} -------")
  MultihostMapping.map_from_name(wagn_name)
end