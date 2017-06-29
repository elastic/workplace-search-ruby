require 'swiftype-enterprise/configuration'
require 'swiftype-enterprise/request'

module SwiftypeEnterprise
  # API client for the {Swiftype Enterprise API}[https://swiftype.com/enterprise-search].
  class Client
    DEFAULT_TIMEOUT = 15

    include SwiftypeEnterprise::Request

    def self.configure(&block)
      warn "`SwiftypeEnterprise::Easy.configure` has been deprecated. Use `SwiftypeEnterprise.configure` instead."
      SwiftypeEnterprise.configure &block
    end

    # Create a new SwiftypeEnterprise::Client client
    #
    # @param options [Hash] a hash of configuration options that will override what is set on the SwiftypeEnterprise class.
    # @option options [String] :access_token an API Key to use for this client
    # @option options [Numeric] :overall_timeout overall timeout for requests in seconds (default: 15s)
    # @option options [Numeric] :open_timeout the number of seconds Net::HTTP (default: 15s)
    #   will wait while opening a connection before raising a Timeout::Error

    def initialize(options={})
      @options = options
    end

    def access_token
      @options[:access_token] || SwiftypeEnterprise.access_token
    end

    def open_timeout
      @options[:open_timeout] || DEFAULT_TIMEOUT
    end

    def overall_timeout
      (@options[:overall_timeout] || DEFAULT_TIMEOUT).to_f
    end

    # Documents have fields that can be searched or filtered.
    #
    # For more information on indexing documents, see the {Content Source documentation}[https://app.swiftype.com/ent/docs/custom_sources].
    module ContentSourceDocuments
      # Retrieve Document Receipts from the API by ID for the {asynchronous API}[https://app.swiftype.com/ent/docs/custom_sources]
      #
      # @param [Array<String>] receipt_ids an Array of Document Receipt IDs
      #
      # @return [Array<Hash>] an Array of Document Receipt hashes
      def document_receipts(receipt_ids)
        post("ent/document_receipts/bulk_show.json", :ids => receipt_ids.join(','))
      end

      # Index a batch of documents using the {asynchronous API}[https://app.swiftype.com/ent/docs/custom_sources].
      # This is a good choice if you have a large number of documents.
      #
      # @param [String] content_source_key the unique Content Source key as found in your Content Sources dashboard
      # @param [String] document_type_id the Document Type slug or ID
      # @param [Array] documents an Array of Document Hashes
      # @param [Hash] options additional options
      # @option options [Boolean] :async (false) When true, output is document receipts created. When false, poll until all receipts are no longer pending or timeout is reached.
      # @option options [Numeric] :timeout (10) Number of seconds to wait before raising an exception
      #
      # @return [Array<Hash>] an Array of newly-created Document Receipt hashes if used in :async => true mode
      # @return [Array<Hash>] an Array of processed Document Receipt hashes if used in :async => false mode
      #
      # @raise [Timeout::Error] when used in :async => false mode and the timeout expires
      def index_documents(content_source_key, documents = [], options = {})
        documents = Array(documents)

        res = async_create_or_update_documents(content_source_key, documents)

        if options[:sync]
          receipt_ids = res["document_receipts"].map { |a| a["id"] }

          poll(options) do
            receipts = document_receipts(receipt_ids)
            flag = receipts.all? { |a| a["status"] != "pending" }
            flag ? receipts : false
          end
        else
          res
        end
      end

      # Destroy a batch of documents given a list of external IDs
      #
      # @param [Array<String>] document_ids an Array of Document External IDs
      #
      # @return [Array<Hash>] an Array of Document destroy result hashes
      def destroy_documents(content_source_key, document_ids = [])
        document_ids = Array(document_ids)
        post("ent/sources/#{content_source_key}/documents/bulk_destroy.json", document_ids)
      end

      private
      def async_create_or_update_documents(content_source_key, documents = [])
        post("ent/sources/#{content_source_key}/documents/bulk_create.json", documents)
      end
    end

    include SwiftypeEnterprise::Client::ContentSourceDocuments
  end
end
