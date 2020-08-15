#!/usr/bin/env ruby
$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib"

require 'plist'
require 'fileutils'
require 'filesize'

FRAMEWORK_NAME = ENV['FRAMEWORK_NAME']
FRAMEWORK_PACKAGE = ENV['FRAMEWORK_PACKAGE']
BASE_VERSION = ENV['BASE_VERSION']

IPA_DIR = ENV['IPA_DIR']
SIZE_REPORT_DIR = ENV['SIZE_REPORT_DIR']

def format_bytes(bytes)
  return Kernel::sprintf("%0.1f MB", Filesize.from(bytes.to_s).to('MB'))
end

def format_variants(variant)
  if !variant['variantDescriptors'].nil?
    # Xcode 10
    return variant['variantDescriptors'].map { |element| "#{element['device']} - iOS #{element['os-version']}"}
  elsif !variant['variantIds'].nil?
    # Xcode 9
    return variant['variantIds']
  else
    return "Universal binary"
  end
end

def create_markdown_snippet(info)
  File.open("#{SIZE_REPORT_DIR}/SizeImpact.md", 'w') do |f|
    f.puts "Architecture | Compressed Size | Uncompressed Size"
    f.puts "------------ | --------------- | -----------------"
    info.sort.map do |key,value|
      f.puts "#{key}        |       #{value['compressed_framework_size']}    | #{value['uncompressed_framework_size']}"
    end
  end
end

FileUtils.rm_rf(SIZE_REPORT_DIR)
FileUtils.mkdir_p(SIZE_REPORT_DIR)

info = {}

File.open("#{SIZE_REPORT_DIR}/#{FRAMEWORK_NAME} Size Impact Report.txt", 'w') do |f|
  f.puts "Size impact report for #{FRAMEWORK_NAME} #{BASE_VERSION}"
  f.puts ""

  app_thinning_plist = Plist.parse_xml("#{IPA_DIR}/app-thinning.plist")

  for variant in app_thinning_plist['variants']
    variant_name = variant[0]
    variant_properties = variant[1]
    variant_architecture = 'arm64'

    `zipinfo -l "${IPA_DIR}/Apps/AppSizer.ipa" | sort -nr -k 6 > file`
    lines = File.readlines("file")
    str = lines[3]
    f.puts str
    terms = str.split(' ')
    uncompressed_framework_size = terms[3]
    compressed_framework_size = terms[5]

    info[variant_architecture] = {'compressed_framework_size' => format_bytes(compressed_framework_size), 'uncompressed_framework_size' => format_bytes(uncompressed_framework_size) }
    
    f.puts "Variant: #{variant_name}"
    f.puts " - Architecture: #{variant_architecture}"
    f.puts " - Devices supported: #{format_variants(variant_properties)}"
    f.puts " - Uncompressed size of #{FRAMEWORK_NAME} framework: #{format_bytes(uncompressed_framework_size)}"
    f.puts " - Compressed size of #{FRAMEWORK_NAME} framework: #{format_bytes(compressed_framework_size)}"
    f.puts ""
  end
end

create_markdown_snippet(info)
