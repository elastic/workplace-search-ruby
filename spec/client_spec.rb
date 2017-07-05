require 'spec_helper'

describe SwiftypeEnterprise::Client do
  let(:engine_slug) { 'swiftype-api-example' }
  let(:client) { SwiftypeEnterprise::Client.new }

  before :each do
    SwiftypeEnterprise.access_token = 'cGUN-vBokevBhhzyA669'
  end

  context 'ContentSourceDocuments' do
    def check_receipt_response_format(response, options = {})
      expect(response.keys).to match_array(["document_receipts", "batch_link"])
      expect(response["document_receipts"]).to be_a_kind_of(Array)
      expect(response["document_receipts"].first.keys).to match_array(["id", "external_id", "links", "status", "errors"])
      expect(response["document_receipts"].first["external_id"]).to eq(options[:external_id]) if options[:external_id]
      expect(response["document_receipts"].first["status"]).to eq(options[:status]) if options[:status]
      expect(response["document_receipts"].first["errors"]).to eq(options[:errors]) if options[:errors]
    end

    let(:content_source_key) { '59542d332139de0acacc7dd4' }
    let(:documents) do
      [{'external_id'=>'INscMGmhmX4',
        'url' => 'http://www.youtube.com/watch?v=v1uyQZNg2vE',
        'title' => 'The Original Grumpy Cat',
        'body' => 'this is a test'},
       {'external_id'=>'JNDFojsd02',
               'url' => 'http://www.youtube.com/watch?v=tsdfhk2j',
               'title' => 'Another Grumpy Cat',
               'body' => 'this is also a test'}]
    end

    context '#document_receipts' do
      before :each do
        def get_receipt_ids
          receipt_ids = nil
          VCR.use_cassette(:async_create_or_update_document_success) do
            receipt_ids = client.async_index_documents(content_source_key, documents)
          end
          receipt_ids
        end
      end

      it 'returns array of hashes one for each receipt' do
        VCR.use_cassette(:document_receipts_multiple) do
          receipt_ids = get_receipt_ids
          response = client.document_receipts(receipt_ids)
          expect(response.size).to eq(2)
          expect(response.first.keys).to match_array(["id", "external_id", "links", "status", "errors"])
        end
      end
    end

    context '#index_documents' do
      it 'returns document_receipts when successful' do
        VCR.use_cassette(:async_create_or_update_document_success) do
          VCR.use_cassette(:document_receipts_multiple_complete) do
            response = client.index_documents(content_source_key, documents)
            expect(response.map(&:keys).map(&:sort)).to eq([["errors", "external_id", "id", "links", "status"], ["errors", "external_id", "id", "links", "status"]])
            expect(response.map { |a| a["status"] }).to eq(["complete", "complete"])
          end
        end
      end

      it 'should timeout if the process takes longer than the timeout option passed' do
        allow(client).to receive(:document_receipts) { sleep 0.05 }

        VCR.use_cassette(:async_create_or_update_document_success) do
          expect do
            client.index_documents(content_source_key, documents, :timeout => 0.01)
          end.to raise_error(Timeout::Error)
        end
      end

      it 'should validate required document fields' do
        documents = [{'external_id'=>'INscMGmhmX4', 'url' => 'http://www.youtube.com/watch?v=v1uyQZNg2vE'}]
        expect do
          client.index_documents(content_source_key, documents)
        end.to raise_error(SwiftypeEnterprise::InvalidDocument, 'missing required fields (title, body)')
      end

      it 'should reject non-core document fields' do
        documents.first['a_new_field'] = 'some value'
        expect {
          client.index_documents(content_source_key, documents)
        }.to raise_error(SwiftypeEnterprise::InvalidDocument, 'unsupported fields supplied (a_new_field), supported fields are (external_id, url, title, body, created_at, updated_at, type)')
      end
    end

    context '#async_index_documents' do
      it 'returns receipt IDs when successful' do
        VCR.use_cassette(:async_create_or_update_document_success) do
          VCR.use_cassette(:document_receipts_multiple_complete) do
            response = client.async_index_documents(content_source_key, documents)
            expect(response.size).to eq(2)
          end
        end
      end
    end

    context '#destroy_documents' do
      it 'returns #async_create_or_update_documents format return when async has been passed as true' do
        VCR.use_cassette(:async_create_or_update_document_success) do
          VCR.use_cassette(:document_receipts_multiple_complete) do
            client.index_documents(content_source_key, documents)
            VCR.use_cassette(:destroy_documents_success) do
              response = client.destroy_documents(content_source_key, [documents.first['external_id']])
              expect(response.size).to eq(1)
              expect(response.first['success']).to eq(true)
            end
          end
        end
      end
    end
  end
end
