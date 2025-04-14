
# 1.0.0 - April 2025

Java-air was extracted from rascal version 0.40.0. The Java analysis framework
as part of the the standard library of Rascal and based on Eclipse's JDT had
existed since 2014. It was initiated by Paul Klint and the first version
was completed byAshim Shahi in 2014. 

Note that users have to add a `<dependency>` tag to their `pom.xml` to be able
to use `java-air`, since the component was extracted from the standard library.

Historical release notes can be found at the [Rascal project](https://www.rascal-mpl.org/release-notes/).

Recently this code has been very active:
* added support for Java 9 through Java 14 constructs
* made the AST extractor satisfy the AST contract in `analysis::m3::AST`
* introduced Java M3 consistency checkers via the contract in `analysis::m3::Core`
* completed and rewrote JVM bytecode extraction  (by Lina Maria Ochoa Venegas)

And java-air has a sister library called ["clair"](https://www.rascal-mpl.org/docs/Packages/Clair/)
for C and C++ analysis. There is also the much older [php-analysis](https://www.rascal-mpl.org/docs/Packages/PhpAnalysis/),
which does not follow the structures of `analysis::m3` yet.
