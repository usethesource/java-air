# Publications

This work motivated the initial Java analysis framework, as well as others (PHP):

```bibtex
@inproceedings{ossmeter1,
     author = {Di Ruscio, Davide and Kolovos, Dimitrios S. and Korkontzelos, Ioannis and Matragkas, Nicholas and Vinju, Jurgen},
      title = {OSSMETER: A Software Measurement Platform for Automatically Analysing Open Source Software Projects},
  booktitle = {ESEC/FSE 2015 Tool Demonstrations Track},
       year = {2015}
}
```

This work makes extensive use of the Java analysis framework, and extended it with flow analysis:
```bibtex
@inproceedings{icse17,
  author = {Davy Landman and Alexander Serebrenik and Jurgen J. Vinju},
  title = {Challenges for Static Analysis of Java Reflection – Literature Review and Empirical Study},
  booktitle = {Proceedings of IEEE International Conference on Software Engineering (ICSE 2017)},
  publisher = {IEEE},
  year = {2017},
  month = may,
}
```

This work uses the Java analysis framework, and also re-imagined the bytecode analysis framework of java-air,
such that fact extraction from bytecode could be compared to, and combined with, the facts extracted from source code.
```bibtex
@inproceedings{msr17,
  author = {Lina Ochoa and Thomas Degueule and Jurgen J. Vinju},
  title = {An Empirical Evaluation of OSGi Dependencies Best Practices in the Eclipse IDE},
  booktitle = {Proceedings of the 15th International Conference  on Mining Software Repositories},
  publisher = {IEEE},
  year = {2018},
}```

In this work java-air is one of the many components used to deeply analyze bytecode and source code
for change impact on a ecosystem scale:
```bibtex
@article{ochoa21,
  author = {L. Ochoa and T. Degueule and J-R. Falleri and J. Vinju},
  journal = {Empirical Software Engineering},
  title = {Breaking Bad? Semantic Versioning and Impact of Breaking Changes in Maven Central},
year = {2021}
}
```

These are the technical reports for the OSSMETER EU project that influenced much of the design of java-air:
* [OSSMETER Deliverable D3.1](https://homepages.cwi.nl/~jurgenv/papers/D3.1ReportonDomainAnalysisofOSSQualityAttributes.pdf) – Report on Domain Analysis of OSS Quality Attributes. EU FP7 STREP Project Deliverable for OSSMETER.
* [OSSMETER Deliverable D3.2](https://homepages.cwi.nl/~jurgenv/papers/D3.2ReportonSourceCodeActivityMetrics.pdf) – Report on Source Code Activity Metrics. EU FP7 STREP Project Deliverable for OSSMETER.
* [OSSMETER Deliverable D3.3](https://homepages.cwi.nl/~jurgenv/papers/D3.3LanguageAgnosticSourceCodeQualityAnalysis.pdf) – Language Agnostic Source Code Quality Analysis. EU FP7 STREP Project Deliverable for OSSMETER.
* [OSSMETER Deliverable D3.4](https://homepages.cwi.nl/~jurgenv/papers/D3.4LanguageSpecificSourceCodeQualityAnalysis.pdf) – Language-Specific Source Code Quality Analysis. EU FP7 STREP Project Deliverable for OSSMETER.


# Specific Releases

Here some citable zenodo snapshots, which you could cite instead of the above
papers. The difference is you credit more the implementation of the work than
the conceptual contribution of Rascal. It's up to you. The author lists are
different, necessarily. So if you depend on a particular piece of work inside
java-air authored by somebody who is not an author of the above papers, then this
should have your preference.

* https://zenodo.org/record/TODO


		
