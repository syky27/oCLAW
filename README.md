#oCLAW


octoprint CLi Api Wrapper

oCLAW is just a CLI to your OctoPrint. OctoPrint is awesome print server, but it's written in JavaScript, which needs a lot of RAM memomy on client's side. And also some users like Terminal more than Web browser.

There will be gem for this soon!!!

In a meantime you can pull this repo, and install all needed gems that are in `oclaw.rb`

## API KEY
Octoprint need API Key (it can be blank) oCLAW takes enviromental variable `OCLAW_API_KEY`
So just set this system variable to your api key and `oCLAW` will start to work.

Then you can run `ruby oclaw.rb list` oCLAW will start to scan your local network in same subnet so for example if your local ip address is `192.168.1.42`, oCLAW will start to scan ip addreses from `192.168.1.0` to `192.168.1.255`, for possible open `80` port.

In case oCLAW finds some it will try to get send a `HTTP` request and find out if the ip address is actually running octoprint.
 
The output should look like this:

```
+----+--------------+---------------+-------------+-------------+-------------+
|                             Available Printers                              |
+----+--------------+---------------+-------------+-------------+-------------+
| ID | Hostname     | IP            | State       | Temp Bed    | Temp Nozzle |
+----+--------------+---------------+-------------+-------------+-------------+
| 0  | Not Resolved | 192.168.1.102 | Operational | 52.2 => 0.0 | 49.5 => 1.0 |
| 1  | Not Resolved | 192.168.1.103 | Operational | 25.5 => 2.0 | 30.4 => 1.0 |
+----+--------------+---------------+-------------+-------------+-------------+
```

## Actions 
### heat
You can use `ruby oclaw.rb heat`, this if what you'll get:

```
+----+--------------+---------------+-------------+-------------+----------------+
|                               Available Printers                               |
+----+--------------+---------------+-------------+-------------+----------------+
| ID | Hostname     | IP            | State       | Temp Bed    | Temp Nozzle    |
+----+--------------+---------------+-------------+-------------+----------------+
| 0  | Not Resolved | 192.168.1.102 | Operational | 32.8 => 0.0 | 108.9 => 230.0 |
| 1  | Not Resolved | 192.168.1.103 | Operational | 25.5 => 2.0 | 25.9 => 1.0    |
+----+--------------+---------------+-------------+-------------+----------------+
Select printer by ID
1
What would you like to heat?
(1) Nozzle
(2) Bed
1
Enter Temperature
230
SUCCESS - Printing live temp change :
Temp Bed : 25.4 => 2.0 Temp Nozzle 27.2 => 230.0
```

oCLAW will start to automaticaly update your temperature status.