require File.expand_path('../helper', __FILE__)

class Crisply < Service::TestCase

  def setup
    @stubs = Faraday::Adapter::Test::Stubs.new
  end
  
  def test_account 
    assert_equal crisply_instance.account, "marcincebula"
  end
  def test_token 
    assert_equal crisply_instance.token, "03RfhhCXLuI6iCeiiG6M"
  end
  def test_project 
    assert_equal crisply_instance.project, "test-project"
  end
  def test_text
    assert_equal crisply_instance.text, "Tom Preston-Werner: stub git call for Grit#heads test f:15 Case#1  @  http://github.com/mojombo/grit/commit/06f63b43050935962f84fe54473a7c5de7977325"
  end
  def test_date
    assert_equal crisply_instance.date, (Time.new "2007-10-10T00:11:02-07:00")
  end
  
  def test_push
    @stubs.post "/api/create.json" do |env|
      assert_equal 'crisply.com', env[:url].host
      assert_equal 'application/xml', env[:request_headers]['content-type']
      [200, {}, '']
    end
    crisply_instance.receive_push
  end

  def crisply_instance
    svc = service :push, {:username => 'marcincebula', :api_key => '03RfhhCXLuI6iCeiiG6M', :project => 'test-project'}, payload
  end

  def service(*args)
    super Service::Crisply, *args
  end
  
  

end
