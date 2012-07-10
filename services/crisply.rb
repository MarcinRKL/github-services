require File.expand_path('../crisply_api.rb', __FILE__)

class Service::Crisply < Service
  def receive_push
    notify unless data_empty?
  end
  
  def notify
  ## This should be a block, I think. I'll figure out how to do that when I'm not so sleepy
   response =  CrisplyApi.post_activity({
     :account => account, 
     :token => token, 
     :project => project, 
     :text => text,
     :date => date
   })
    puts response.methods
    puts response.body
    # if response. < 200 || response.status > 299
    #   raise_config_error
    # end
  end
  
  
  
  def data_empty?
    if account.empty? 
      raise_config_error "Needs a username: https://<UserName>.crisply.com/"    
      return true
    elsif token.empty?
      raise_config_error "Needs a API Key: http://support.crisply.com/customer/portal/articles/250733-overview"    
      return true
    elsif project.empty?
      raise_config_error "Needs project-name"    
      return true
    else
      return false
    end
  end
  
  def account 
    data[:username].to_s
  end
  def token 
    data[:api_key].to_s 
  end
  def project
    data[:project].to_s 
  end
  def text
    "#{payload['commits'][0]['author']['name']}: #{payload['commits'][0]['message']}  @  #{payload['commits'][0]['url']}"
  end
  ## Almost positive this is wrong. Check it tomorrow.
  def date
    Time.new payload['commits'][0]['timestamp']
  end
  
end

