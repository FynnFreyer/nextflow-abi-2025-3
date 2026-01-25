process say_hello {
  output:
    stdout
  exec:
    println('Hello!')
}

workflow {
  say_hello | view
}
