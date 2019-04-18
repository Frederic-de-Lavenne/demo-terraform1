
# # create an user named certbot
# resource "aws_iam_user" "certbot" {
#   name = "certbot"
#   path = "/users/"
# }

# # create access token for certbot user
# resource "aws_iam_access_key" "certbot" {
#   user = "${aws_iam_user.certbot.name}"
# }

# # attach policy for certbot user
# resource "aws_iam_policy_attachment" "attach-to-certbot" {
#     name       = "certbot-policy"
#     policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
# }
