require 'spec_helper'
require 'gds-sso/api_access'

describe GDS::SSO::ApiAccess do
  it "should not consider IE7 accept header as an api call" do
    ie7_accept_header = 'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, ' +
      'application/x-shockwave-flash, application/xaml+xml, application/x-ms-xbap, ' +
      'application/x-ms-application, */*'
    expect(GDS::SSO::ApiAccess.api_call?('HTTP_ACCEPT' => ie7_accept_header)).to be_false
  end

  it "should consider a json accept header to be an api call" do
    expect(GDS::SSO::ApiAccess.api_call?('HTTP_ACCEPT' => 'application/json')).to be_true
  end
end
