#!/bin/bash

passenger stop -p 3456
passenger start -p 3456 --user webmail -d
