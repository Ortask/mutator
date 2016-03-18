Mutator
==========================================

Quick, scalable and painless mutation analysis for Ruby, Java and many other languages.
------

Mutator is the world's leading mutation analyzer. It is a cross-language, high performance mutation analyzer for Ruby and Java (and more languages coming soon!)

[As this proof shows](https://gist.github.com/louismrose/11849546efd8cf496fc2#comment-1261635), neither mutant nor pitest can perform full mutation analysis. Mutator rights that wrong.

Mutator does full mutation analysis by enabling:
- the competent programmer hypothesis
- the coupling effect

[See this video](http://www.confreaks.com/videos/3274-mwrc-re-thinking-regression-testing) to learn how Mutator works and why partial mutation testers (like mutant and pitest) are simply useless.

Read more on the [Ortask website](http://ortask.com/mutator/).



Using Mutator
-----------

Mutator is available in either a standalone version, or as an embeddable component. 

The commercial and enterprise editions of Mutator can also increase the quality of your tests for concurrent applications (something that mutant and pitest can't do). [Download from here](http://ortask.com/mutator/).

 

Extending Mutator
---------------

We encourage experimentation with Mutator. You can build extensions to Mutator, develop library or drivers atop the product, or make contributions directly to the product core. You'll need to sign a [Contributor License Agreement](http://ortask.com/ortask-cla/) in order for us to accept your patches.


Building Mutator
--------------

Mutator is ready-to-run, so there is currently no need to build. You only need Ruby version 1.9.3 or later.


Licensing
---------

Mutator is an open source product. The product is available under the AGPLv3 license for open source projects otherwise under a commercial license from [Ortask](http://ortask.com/pricing-ortask-mutator/).
