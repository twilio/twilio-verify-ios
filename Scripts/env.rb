#!/usr/bin/env ruby
exit 1 unless ARGV[0]

exec "bash -c 'source Scripts/env.sh && /usr/bin/env ruby #{ARGV[0]}'"
