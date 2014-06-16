oCLAW
=====

octoprint CLi Api Wrapper

oCLAW is just a CLI to your OctoPrint. OctoPrint is awesome print server, but it's written in JavaScript, which needs a lot of RAM memomy on client's side. And also some users like Terminal more than Web browser.

Install script will create `.config.json` file in your home directory, it looks like this:

    {
        "printers": [
            {
                "printer": {
                    "name" :"home",
                    "url": "172.16.60.123",
                    "port": 5000,
                    "apikey": "42fekals",
                    "select": "true",
                    "print": "false",
                    "location":"local"
                }
            },
            {
                "printer": {
                    "name": "work",
                    "url": "172.16.60.133",
                    "port": 5000,
                    "apikey": "fekal_fekal",
                    "select": "true",
                    "print": "false",
                    "location":"local"
                }
            }
        ]
    }


![](https://raw.githubusercontent.com/syky27/oCLAW/master/OP_API_KEY.png)


You can set API key to whatever you want it's setting is in octoprint frontend or you can set apikey in Octoprint's `comfig.yaml`

`"select": "true"` `select` can be `true` or `false` it says if uploaded file will be set as selected to be ready to print.


`"print": "false"` `print` is also boolean and it says if the print is supposed to start right away after file uploading


`"location": "local"` `location` set's you main storage, `local`  or  `sdcard`


Examples:
//`oclaw -mu 172.16.60.133 ~/my.gcode` - thats the plan not working yet

Current:
oclaw [printer_name] [path_to_file]





