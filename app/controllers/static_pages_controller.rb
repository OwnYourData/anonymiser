class StaticPagesController < ApplicationController
    include ApplicationHelper
    include AnonHelper

    def home
        @soya = ''
        @data = ''
        @result = ''
    end

    def example
        @soya = 'AnonymisationDemo'
        file_path = Rails.root.join("app", "data", "example.json")
        @data = JSON.pretty_generate(JSON.parse(File.read(file_path)))
        # result_path = Rails.root.join("app", "data", "result.json")
        @result = '' # JSON.parse(File.read(result_path))
        render 'home'
    end

    def submit
        input_data = JSON.parse(params[:data]) rescue nil
        @soya = params[:model]
        action = params[:commit]

        if (action.to_s == 'Anonymise' || action.to_s == 'Export to TTL') && !input_data.nil?
            anonymize_url = 'https://anonymizer.go-data.at/api/anonymise'
            object_data = {
                configurationURL: 'https://soya.ownyourdata.eu/' + @soya.to_s,
                data: input_data
            }
            rensponse_nil = false
            begin
                object_response = HTTParty.put(anonymize_url, 
                    headers: { 'Content-Type'  => 'application/json' },
                    body: object_data.to_json )
            rescue => ex
                response_nil = true
            end
            if !response_nil
                parsed = JSON.parse(object_response.body)
                if action.to_s == 'Export to TTL'

                    acquire_url = 'https://soya-web-cli.ownyourdata.eu/api/v1/acquire/' + @soya.to_s
                    acquire_data = parsed["anonymisedData"]
                    rensponse_nil = false
                    begin
                        acquire_response = HTTParty.post(acquire_url, 
                            headers: { 'Content-Type'  => 'application/json' },
                            body: acquire_data.to_json )
                    rescue => ex
                        response_nil = true
                    end
                    if !response_nil
                        graph = RDF::Graph.new << JSON::LD::Reader.new(acquire_response.body)
                        render plain: graph.dump(:turtle, standard_prefixes: true),
                               content_type: 'text/turtle',
                               status: 200
                        return
                    end
                end
                @result = JSON.pretty_generate(parsed["anonymisedData"])
            end
        elsif action.to_s == 'Reset'
            redirect_to root_path
            return
        else
            @soya = ''
            @data = ''
            @result = ''
            input_data = nil
        end
        @data = JSON.pretty_generate(input_data) rescue nil
        if @data == "null"
            @data = ''
        end
        render :home
    end
end