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
                    "apikey": "r3pr4pfit",
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





Examples:
`oclaw -mu 172.16.60.133 ~/my.gcode`



