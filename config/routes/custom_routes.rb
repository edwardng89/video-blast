##
# Routes for Custom
module CustomRoutes
  def self.extended(router)
    router.instance_exec do
      extend PublicRoutes
      # Insert Custom Routes here
    end
  end
end
