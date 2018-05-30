output "jboss-elb-dns" {
  value = "${aws_elb.jboss-elb.dns_name}"
}
