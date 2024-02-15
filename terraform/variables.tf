#ukazka ako mozes mat viac premmenych v mape a nemusis opakovat x krat variable.... ale potom to volat z mapy
variable "config" {
  description = "Configuration variables"
  type        = map(object({
    location = string
    project  = string
  }))
  default = {
    location = "europe-west1"
    project  = "sb-devel"
  }
  validation {
    condition     = can(index(["europe-west1", "region2", "region3"], var.config.location)) # nemusis davat validaciu ale aj taketo nieco v tf existuje na validovanie vstupov
    error_message = "Vyber validny region."
  }
}