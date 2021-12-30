#!/bin/bash

mongosh <<EOMONGO1
   	var cfg = {
		"_id": "rsAPS",
			"version": 1,
				"members": [{
					"_id": 0,
					"host": "mongo-0.mongo:27017",
					"priority": 2
				},
				{
					"_id": 1,
					"host": "mongo-1.mongo:27017",
					"priority": 0
				},
				{
					"_id": 2,
					"host": "mongo-2.mongo:27017",
					"priority": 0
				}]
	};
	rs.initiate(cfg, { force: true });
	//rs.reconfig(cfg, { force: true });
	rs.status();
EOMONGO1

sleep 30

mongosh <<EOMONGO2
	use admin;
	admin = db.getSiblingDB("admin");
	admin.createUser({
		user: "admin",
		pwd: "omnissiah",
		roles: [ { role: "root", db: "admin" } ]
	});
	
	db.getSiblingDB("admin").auth("admin", "omnissiah");
	rs.status();
EOMONGO2
