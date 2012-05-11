#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'csv'
require 'json'
require 'net/http'

ARGV.each do |a|
  if @arquivo_csv.nil?
    @arquivo_csv = a
  else
    @arquivo_json = a
  end
end

if @arquivo_csv.nil? || @arquivo_json.nil?
  puts "Modo de uso: parse_csv_to_json.rb <CSV> <JSON>"
  exit
end

unless File.exists? @arquivo_csv
  puts "O arquivo #{@arquivo_csv} não existe."
  exit
end

consociais_csv = CSV.read(@arquivo_csv, :col_sep => ';')

# Retira o nome das colunas no array de consociais
colunas = consociais_csv.shift 

consociais_json = []

sucessos = 0
erros = 0

consociais_csv.each do |linha|
  consocial = { :titulo => '', :campos => [] }
  endereco = ''

  linha.each_index do |i|
    # Pula a coluna ID
    next if i == 0

    if colunas[i] == 'CIDADE TITULO'
      endereco = linha[i]
      consocial[:titulo] = linha[i]
      next
    elsif colunas[i] == 'UF'
      endereco = "#{linha[i]} #{endereco}"
    end

    campo = {}
    campo[colunas[i]] = linha[i]

    consocial[:campos].push campo
  end

  # Busca lat e long da API do google maps
  uri = URI('http://maps.googleapis.com/maps/api/geocode/json')
  uri.query = URI.encode_www_form({ :address => endereco, :sensor => false })
  proxy_class = Net::HTTP::Proxy('10.1.101.101', 8080)

  proxy_class.start(uri.host, uri.port) do |http|
    request = Net::HTTP::Get.new uri.request_uri
    http.request request do |response|
      geocoding = JSON.parse(response.body)

      if geocoding["status"] == "OK" 
        consocial[:lat] = geocoding["results"][0]["geometry"]["location"]["lat"]
        consocial[:lng] = geocoding["results"][0]["geometry"]["location"]["lng"]
        puts "Sucesso: Item #{linha[0]} - #{endereco}, lat: #{consocial[:lat]}, lng: #{consocial[:lng]}"
        sucessos = sucessos + 1
      else
        puts "Erro: Item #{linha[0]} - #{endereco}. Código: #{geocoding['status']}"
        erros = erros + 1
      end
    end
  end

  consociais_json.push consocial
end

puts ""
puts "--------------------------------------------"
puts "Encontrados: #{sucessos}        Não encontrados: #{erros}"
puts "--------------------------------------------"

File.open(@arquivo_json, 'w') { |f| f.write(JSON.generate(consociais_json)) }
