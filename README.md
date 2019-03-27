<p align="center"><img src="https://github.com/swiftype/swiftype-enterprise-ruby/blob/master/logo-enterprise-search.png?raw=true" alt="Elastic Enterprise Search Logo"></p>

<a href="https://github.com/swiftype/swiftype-enterprise-ruby/releases"><img src="https://img.shields.io/github/release/swiftype/swiftype-enterprise-ruby/all.svg?style=flat-square" alt="GitHub release" /></a></p>

> A first-party Ruby client for [Elastic Enterprise Search](https://www.elastic.co/solutions/enterprise-search).

## Contents

+ [Getting started](#getting-started-)
+ [Usage](#usage)
+ [FAQ](#faq-)
+ [Contribute](#contribute-)
+ [License](#license-)

***

## Getting started 🐣

To install the gem, execute:

```bash
gem install swiftype-enterprise
```

Or place `gem 'swiftype-enterprise', '~> 1.0.0` in your `Gemfile` and run `bundle install`.

## Usage

Create a new instance of the Swiftype Enterprise Client with your access token:

    SwiftypeEnterprise.access_token = '' # your access token
    swiftype = SwiftypeEnterprise::Client.new

### Indexing Documents

This example shows how to use the index_documents method, which blocks until all documents have either completed or failed indexing.

If not all of the documents have completed or failed indexing within 10 seconds, an Error is raised.
See the async_index_documents method below for an example on how to index documents without blocking.

    content_source_key = '' # your content source key
    documents = [
      {
        'external_id' => 'INscMGmhmX4',
        'url' => 'http://www.youtube.com/watch?v=v1uyQZNg2vE',
        'title' => 'The Original Grumpy Cat',
        'body' => 'this is a test'
      },
      {
        'external_id' => 'JNDFojsd02',
        'url' => 'http://www.youtube.com/watch?v=tsdfhk2j',
        'title' => 'Another Grumpy Cat',
        'body' => 'this is also a test'
      }
    ]

    begin
      document_receipts = swiftype.index_documents(content_source_key, documents)
      # handle document receipts
    rescue SwiftypeEnterprise::ClientException => e
      # handle error
    end

### Destroying Documents

    content_source_key = '' # your content source key
    document_external_ids = ['INscMGmhmX4', 'JNDFojsd02']

    begin
      destroy_document_results = swiftype.destroy_documents(content_source_key, document_external_ids)
      # handle destroy document results
    rescue SwiftypeEnterprise::ClientException => e
      # handle error
    end

### Asynchronous Indexing

This example shows how to index documents without blocking.
When using this method, you are responsible for checking the indexing result for each document by using the document_receipts method below.

    content_source_key = '' # your content source key
    documents = [
      {
        'external_id' => 'INscMGmhmX4',
        'url' => 'http://www.youtube.com/watch?v=v1uyQZNg2vE',
        'title' => 'The Original Grumpy Cat',
        'body' => 'this is a test'
      },
      {
        'external_id' => 'JNDFojsd02',
        'url' => 'http://www.youtube.com/watch?v=tsdfhk2j',
        'title' => 'Another Grumpy Cat',
        'body' => 'this is also a test'
      }
    ]

    begin
      document_receipt_ids = swiftype.async_index_documents(content_source_key, documents)
      # handle document receipt IDs
    rescue SwiftypeEnterprise::ClientException => e
      # handle error
    end


### Checking Document Receipts

Works in conjunction with the asyncIndexDocuments method above.

    content_source_key = '' # your content source key
    document_receipt_ids = ['5955d6fafd28400169baf97e', '5955d6fafd28400169baf980'] // from calling async_index_documents

    begin
      document_receipts = swiftype.document_receipts(document_receipt_ids)
      # handle document receipts
    rescue SwiftypeEnterprise::ClientException => e
      # handle error
    end

## Running tests

Run tests via rspec:

```bash
$ rspec
```

## FAQ 🔮

### Where do I report issues with the client?

If something is not working as expected, please open an [issue](https://github.com/swiftype/swiftype-enterprise-ruby/issues/new).

## Contribute 🚀

We welcome contributors to the project. Before you begin, a couple notes...

+ Before opening a pull request, please create an issue to [discuss the scope of your proposal](https://github.com/swiftype/swiftype-enterprise-ruby/issues).
+ Please write simple code and concise documentation, when appropriate.

## License 📗

[MIT](https://github.com/swiftype/swiftype-enterprise-ruby/blob/master/LICENSE) © [Elastic](https://github.com/elastic)

Thank you to all the [contributors](https://github.com/swiftype/swiftype-enterprise-ruby/graphs/contributors)!
