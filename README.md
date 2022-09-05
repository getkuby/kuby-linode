## kuby-linode

Linode provider for [Kuby](https://github.com/getkuby/kuby-core).

## Intro

In Kuby parlance, a "provider" is an [adapter](https://en.wikipedia.org/wiki/Adapter_pattern) that enables Kuby to deploy apps to a specific cloud provider. In this case, we're talking about [Linode](https://www.linode.com/).

All providers adhere to a specific interface, meaning you can swap out one provider for another without having to change your code.

## Usage

Enable the Linode provider like so:

```ruby
Kuby.define('MyApp') do
  environment(:production) do
    kubernetes do

      provider :linode do
        access_token 'my-linode-access-token'
        cluster_id 'my-cluster-id'
      end

    end
  end
end
```

Once configured, you should be able to run all the Kuby rake tasks as you would with any provider.

## Locating Your Cluster ID

The cluster ID can be found by visiting your Kubernetes cluster's summary page in the Linode dashboard. On that page, the ID will be included in the URL and as part of the name of each node in the node pool:

![image](https://user-images.githubusercontent.com/575280/188511347-79263953-1abe-45ee-91d2-56710c037450.png)

In the URL:

![image](https://user-images.githubusercontent.com/575280/188511380-532b7717-54a5-43b3-b2e8-2c4af3d23267.png)

## License

Licensed under the MIT license. See LICENSE for details.

## Authors

* Cameron C. Dutro: http://github.com/camertron
