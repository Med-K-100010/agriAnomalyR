# Avoid R CMD check notes for tidy evaluation
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(".data", "value", "sensor"))
}
