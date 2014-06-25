name             "newrelic_sidekiq_agent"
maintainer       "Rahil Sondhi"
maintainer_email "rahilsondhi@gmail.com"
license          "Apache 2"
description      "Installs newrelic_sidekiq_agent by Steven Eksteen and configures runit service"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.2"
%w(runit).each do |cookbook|
  depends cookbook
end