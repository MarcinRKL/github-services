require 'rubygems'
require 'rest_client'
require 'nokogiri'

class CrisplyApi
  
  def self.post_activity options    
    ##Don't like something about this. Think about it later
    resource = CrisplyApi.new(options)
    resource.override_defaults_with options
    project_id = resource.get_project_id_by_name options[:project]
    params = resource.override_defaults_with({:project_id => project_id})
    activity_item = resource.build_xml_request params
    resource.create_new_activity activity_item
  end
  
  def self.get(uri, key)
    ## Remainder: Way too much shit happening!!! 
    url = URI.parse uri
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    http.instance_eval { @ssl_context = OpenSSL::SSL::SSLContext.new(:TLSv1) }
    request = Net::HTTP::Get.new(url.path)
    CrisplyApi.headers.each { |key, value| request.add_field(key, value) }
    request.add_field("X-Crisply-Authentication", key)
    response = http.start {|http| http.request(request) }
    XmlSimple.xml_in(response.body)
  end
  
  def self.post(uri, key, xml)
    ## Remainder: Way too much shit happening!!! 
    url = URI.parse uri
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    http.instance_eval { @ssl_context = OpenSSL::SSL::SSLContext.new(:TLSv1) }
    request = Net::HTTP::Post.new(url.path)
    CrisplyApi.headers.each { |key, value| request.add_field(key, value) }
    request.add_field("X-Crisply-Authentication", key)
    request.content_type = 'text/xml'
    request.body = xml
    response = http.start {|http| http.request(request) }
  end
  
  def self.defaults
    defaults = {}
    defaults[:account] = ""
    defaults[:author] = ""
    defaults[:key] = defaults[:token] = ""
    defaults[:text] = ""
    defaults[:date] = Time.now
    defaults[:guid] = 'post-activity-' + Time.now.to_f.to_s + "-" + Kernel.rand(2**64).to_s
    defaults[:project_id] = ""
    defaults[:duration] = '1'
    defaults[:type] = "task"
    defaults[:deployment_domain] = "crisply.com"
    # defaults[:verbose] = "--[no-]verbose"
    # defaults[:tag] = list
    defaults
  end
  
  def self.headers 
    {
      'Content-Type' => 'application/xml',
      'Accept' =>       'application/xml; charset=utf-8'
    }
  end
  

## CrisplyApi should do data calls like POST, GET, PUT, DELETE and be
## a public API for what the resource classes are doing. 
## Even better if  POST, GET, PUT, DELETE were in a base class.
## No need for the programmer to worry about how the calls are being made
##
##----------------------------------------------------------------------------------------------
## This should be its own class or classes
## Projects and Activities or something like that
## 
## It might be a good idea to wrap all the @params in function for easier testing mocking/stubing
##
##
## If this code didn't live inside this project I would change how these function interact.
## There is absolutally no reason why get_projects should be a function. It should be part
## of the Projects resource. I hate writing bad code and knowing it's bad. I WILL REFACTOR THIS LATER


  def initialize options
    @defaults = CrisplyApi.defaults
    @params = override_defaults_with options
  end

  def get_projects
    CrisplyApi.get(projects_url, @params[:token])
  end
  def create_new_activity(activity_item)
    CrisplyApi.post(activity_items_url, @params[:token], activity_item)
  end
  
  def account_url
    "https://#{@params[:account]}.crisply.com/timesheet/api"
  end
  def projects_url
    "#{account_url}/projects.xml"
  end
  def activity_items_url
    "#{account_url}/activity_items.xml"
  end
  def override_defaults_with options
    @defaults.each do |key, value|
      if options[key] 
        @defaults[key] = options[key] 
      end
    end
  end
  
  def get_project_id_by_name(project_name)
    projects = (CrisplyApi.get(projects_url, @defaults[:token]))['project']
    projects.each do |project|
      if project['name'].first == project_name
        return project['id']
      end
    end
    raise 'Incorrect project name'
  end
  
  
  def build_xml_request options
    options[:date] = options[:date].xmlschema if options[:date]
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.send('activity-item',
        'xmlns' => 'http://crisply.com/api/v1') {
        [:guid, :text, :date, :type, :author, :duration, :project_id].each do |attr|
          value = options[attr]
          unless value.nil?
            xml.send((attr.to_s.gsub('_','-') + '_').to_sym, value)
          end
        end
        if options[:tag]
          xml.tags {
            options[:tag].each do |tag|
              xml.tag tag
            end
          }
        end
      }
    end
    xml = builder.to_xml
  end
  
end 




