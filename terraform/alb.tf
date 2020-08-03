# Start by creating the ALB that attaches to the 
# relevant public subnets
resource "aws_alb" "webservers" {
  name            = "webservers-ecs"
  subnets         = aws_subnet.publics.*.id
  security_groups = ["${aws_security_group.alb.id}"]
}

# Create a target group for the http webservers
resource "aws_alb_target_group" "webservers_http" {
  name        = "webservers-ecs-http"
  port        = var.webservers_http_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "webservers_http" {
  load_balancer_arn = aws_alb.webservers.id
  port              = var.webservers_http_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.webservers_http.id
    type             = "forward"
  }
}

# Create a target group for the websockets
resource "aws_alb_target_group" "webservers_websockets" {
  name        = "webservers-ecs-websockets"
  port        = var.webservers_websockets_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "webservers_websockets" {
  load_balancer_arn = aws_alb.webservers.id
  port              = var.webservers_websockets_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.webservers_websockets.id
    type             = "forward"
  }
}
