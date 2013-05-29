# remoteBox

Sinatra App that gives you access to content of your Dropbox. It will be used
to host documents out of Dropbox to other users. It is designed to be deployed
on Heroku.

> based on dropbox-sdk-example web_file_browser.rb

## Configuration

remoteBox is configured through environment variables, because Heroku allows
you to set them through the `heroku` command. For local development you should
set them at command line:

```
$ APP_KEY=.... APP_SECRET=.... ACCESS_TOKEN=.... ACCESS_SECRET=.... \
AUTH_USERNAME=user AUTH_PASSWORD=password bundle exec shotgun

== Shotgun/Thin on http://0.0.0.0:9393/
>> Thin web server (v1.5.1 codename Straight Razor)
>> Maximum connections set to 1024
>> Listening on 0.0.0.0:9393, CTRL+C to stop
```

## License

remoteBox - sinatra app that gives you access to your dropbox

Copyright (C) 2013 Philipp Böhm

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the 
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
