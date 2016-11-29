# lua-resty-influxdb-relay
A Lua resty service to replicate InfluxDB data for high availability

Table of Contents
=================

* [Name](#name)
* [Status](#status)
* [Synopsis](#synopsis)
* [Installation](#installation)
* [Authors](#authors)
* [Copyright and License](#copyright-and-license)

Status
======
This library is still under early development and experimental.

Synopsis
========
```lua
    # --------- relay config begin --------------
    	lua_code_cache on;
    	lua_package_path "/path/to/openresty/lualib/?.lua;/path/to/lua-resty-influxdb-relay/lib/?.lua;;";
    	lua_package_cpath "/path/to/openresty/lualib/?.so;;";
    	lua_need_request_body on;
    	lua_shared_dict relay 1m;
    	init_by_lua_file '/path/to/lua-resty-influxdb-relay/lib/relay/init.lua';
    # --------- relay config end ----------------

    upstream backend_master {
      server 127.0.0.1: 8086;
    }
    
    upstream backend_slave {
      server 127.0.0.1: 18086;
    }
    
    upstream backend_relay {
      server 127.0.0.1: 8086;
      server 127.0.0.1: 18086;
    }
    
    server {
      server_name influxdb-relay;
      listen 80 backlog = 16384;
      default_type text/plain;
      access_log logs/influxdb-relay.access main;
      log_subrequest on;
    
      location = /write {
        set $backend_uri_args '';
        rewrite_by_lua_file '/path/to/lua-resty-influxdb-relay/lib/relay/rewrite.lua';
      }
    
      location = /query {
        proxy_pass http://backend_relay;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Connection "";
        proxy_http_version 1.1;
        rewrite_by_lua_file '/path/to/lua-resty-influxdb-relay/lib/relay/rewrite_query.lua';
      }
    
      location = /relay_master {
        proxy_pass http://backend_master;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Connection "";
        proxy_http_version 1.1;
        rewrite_by_lua_file '/path/to/lua-resty-influxdb-relay/lib/relay/rewrite_relay.lua';
      }
    
      location = /relay_slave {
        proxy_pass http://backend_slave;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Connection "";
        proxy_http_version 1.1;
        rewrite_by_lua_file '/path/to/lua-resty-influxdb-relay/lib/relay/rewrite_relay.lua';
      }
    
    }
```

[Back to TOC](#table-of-contents)

Installation
============

lua-resty-influxdb-relay use [lua-resty-ini](https://github.com/doujiang24/lua-resty-ini) to parse the ini configuration.
And you should install it with [opm](https://github.com/openresty/opm#readme) just like that: opm install doujiang24/lua-resty-ini

[Back to TOC](#table-of-contents)

Authors
=======

kwanhur <huang_hua2012@163.com>, VIPS Inc.

[Back to TOC](#table-of-contents)

Copyright and License
=====================

This module is licensed under the Apache License Version 2.0 .

Copyright (C) 2016, by kwanhur <huang_hua2012@163.com>, VIPS Inc.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[Back to TOC](#table-of-contents)