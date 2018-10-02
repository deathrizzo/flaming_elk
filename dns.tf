resource "aws_route53_record" "flaming_elk" {
   zone_id = "${var.route53_zone_id}"
   name = "${var.hostname}"
   type = "A"
   ttl = "300"
   records = ["${aws_instance.flaming_elk.public_ip}"]
}
