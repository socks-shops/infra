# # Rôle IAM pour le Service Account operator_db
# resource "aws_iam_role" "operator_db" {
#   name = "${var.cluster_name}-operator_db-role"
#   assume_role_policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "Federated" : "arn:aws:iam::${var.account_id}:oidc-provider/${replace(var.oidc_provider, "https://", "")}"
#         },
#         "Action" : "sts:AssumeRoleWithWebIdentity",
#         "Condition" : {
#           "StringEquals" : {
#             "${replace(var.oidc_provider, "https://", "")}:sub" : "system:serviceaccount:operator_db:operator_db"
#           }
#         }
#       }
#     ]
#   })

#   # # Assurez-vous que votre module EKS est bien référencé et expose oidc_provider_arn
# }

# resource "aws_iam_policy" "operator_db" {
#   name        = "${var.cluster_name}-operator_db-policy"
#   description = "IAM policy for operator_db backups on EKS"
#   # Charge la politique depuis le fichier JSON externe
#   policy      = file("${path.module}/aws_operator_db_policy.json")
#   #
# }

# # Attacher la politique au rôle operator_db
# resource "aws_iam_role_policy_attachment" "operator_db" {
#   policy_arn = aws_iam_policy.operator_db.arn
#   role       = aws_iam_role.operator_db.name
#   #
# }
