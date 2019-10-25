# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Import .whl files into Bazel."""

def _whl_impl(repository_ctx, binary_name):
  """Core implementation of whl_library."""

  args = [
    binary_name,
    repository_ctx.path(repository_ctx.attr._script),
    "--whl", repository_ctx.path(repository_ctx.attr.whl),
    "--requirements", repository_ctx.attr.requirements,
  ]

  if repository_ctx.attr.extras:
    args += [
      "--extras=%s" % extra
      for extra in repository_ctx.attr.extras
    ]

  result = repository_ctx.execute(args)
  if result.return_code:
    fail("whl_library failed: %s (%s)" % (result.stdout, result.stderr))


def _whl2_library_impl(repository_ctx):
  """Python 2 implementation."""
  _whl_impl(repository_ctx, "python")

def _whl3_library_impl(repository_ctx):
  """Python 3 implementation."""
  _whl_impl(repository_ctx, "python3")

whl_library = repository_rule(
    attrs = {
        "whl": attr.label(
            allow_files = True,
            mandatory = True,
            single_file = True,
        ),
        "requirements": attr.string(),
        "extras": attr.string_list(),
        "_script": attr.label(
            executable = True,
            default = Label("//tools:whltool.par"),
            cfg = "host",
        ),
    },
    implementation = _whl2_library_impl,
)

"""A rule for importing <code>.whl</code> dependencies into Bazel.

<b>This rule is currently used to implement <code>pip_import</code>,
it is not intended to work standalone, and the interface may change.</b>
See <code>pip_import</code> for proper usage.

This rule imports a <code>.whl</code> file as a <code>py_library</code>:
<pre><code>whl_library(
    name = "foo",
    whl = ":my-whl-file",
    requirements = "name of pip_import rule",
)
</code></pre>

This rule defines a <code>@foo//:pkg</code> <code>py_library</code> target.

Args:
  whl: The path to the .whl file (the name is expected to follow [this
    convention](https://www.python.org/dev/peps/pep-0427/#file-name-convention))

  requirements: The name of the pip_import repository rule from which to
    load this .whl's dependencies.

  extras: A subset of the "extras" available from this <code>.whl</code> for which
    <code>requirements</code> has the dependencies.
"""


whl3_library = repository_rule(
    attrs = {
        "whl": attr.label(
            allow_files = True,
            mandatory = True,
            single_file = True,
        ),
        "requirements": attr.string(),
        "extras": attr.string_list(),
        "_script": attr.label(
            executable = True,
            default = Label("//tools:whltool.par"),
            cfg = "host",
        ),
    },
    implementation = _whl3_library_impl,
)

"""A rule for importing <code>.whl</code> dependencies into Bazel.

<b>This rule is currently used to implement <code>pip_import</code>,
it is not intended to work standalone, and the interface may change.</b>
See <code>pip_import</code> for proper usage.

This rule imports a <code>.whl</code> file as a <code>py_library</code>:
<pre><code>whl3_library(
    name = "foo",
    whl = ":my-whl-file",
    requirements = "name of pip_import rule",
)
</code></pre>

This rule defines a <code>@foo//:pkg</code> <code>py_library</code> target.

Args:
  whl: The path to the .whl file (the name is expected to follow [this
    convention](https://www.python.org/dev/peps/pep-0427/#file-name-convention))

  requirements: The name of the pip_import repository rule from which to
    load this .whl's dependencies.

  extras: A subset of the "extras" available from this <code>.whl</code> for which
    <code>requirements</code> has the dependencies.
"""
