#!/usr/bin/ruby

$: << "../lib"
#require 'rubygems'
require 'javaclass'
require 'find'

Find.find( ARGV[0]) { |f|
  next unless f =~ /.*\.jar$/
  JavaClass::ZipUtils.each_class( f ) {|cl|
    puts "#{cl.name} (#{f})" if cl.super_class =~ /#{ARGV[1]}/
  }
}