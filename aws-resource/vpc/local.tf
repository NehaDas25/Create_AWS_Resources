###########################################################
#                    Availability Zones
###########################################################
locals{
    azs = ["${var.region}a", "${var.region}b"]
}