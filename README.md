Wormly-Public Cookbook
=============

[Wormly](https://wormly.com) provides a [Chef](http://www.getchef.com/chef/) cookbook automating installation of [Collectd](https://collectd.org/) configured for sending data to Wormly servers.

Requirements
------------

#### cookbooks
- `apt`
- `yum`

Usage
-----

There are no recipes, just one provider:

#### wormly_collectd_public

The shortest way to use this provider is as follows:

`wormly_public_collectd "APIKEY"`

Full syntax, as usual, is similar to:

```
wormly_public_collectd "install monitoring" do
    apikey "APIKEY"
    hostid 1234
    hostname "db-server-1"
end
```

You can get an apikey from a [corresponding page on Wormly website](https://www.wormly.com/apikeys), it needs to have `Host::Health::Submit` permission.

#####resources (options)

* `apikey` (required) - API key, taken from name if missing in the body of provider.
* `hostid` - id of the host on Wormly website. This is optional, but highly recommended as it allows the service to bind the hostname collectd submits to the host as seem in the rest of the system. If omitted, you'll need to assign the hostname on the host's page manually.
* `hostname` - hostname collectd will use, defaults to `hostname`.

Provider supports setting the configuration for MySQL monitoring with the following options:

* `mysqlpassword` - MySQL password. If this is missing, MySQL configuration is disabled.
* `mysqluser` - MySQL user, defaults to `root`.
* `mysqlhost` - MySQL host, defaults to `localhost`.
* `mysqlsocket` - MySQL socket file, empty by default.
* `mysqlport` - MySQL port, defaults to `3306`.

