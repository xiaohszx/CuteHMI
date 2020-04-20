import qbs
import qbs.File
import qbs.FileInfo
import qbs.TextFile

/**
  Skeletal files generator for C++ extensions. Generated files are not treated as artifacts.
  */
Module {
	additionalProductTypes: ["cutehmi.skeleton.cpp"]

	property bool generateCommon: true

	property bool generateException: true

	property bool generatePlatform: true

	property bool generateMetadata: true

	property bool generateLogging: true

	property bool generateQMLPlugin: false

	property bool generateLoggingTest: generateLogging

	property bool generateTestsQbs: generateLoggingTest

	readonly property string commonHeader: product.cutehmi.conventions.internalIncludeDir + "/common.hpp"

	readonly property string exceptionHeader: product.cutehmi.conventions.includeDir + "/Exception.hpp"

	readonly property string loggingHeader: product.cutehmi.conventions.includeDir + "/logging.hpp"

	readonly property string loggingSource: product.cutehmi.conventions.sourceDir + "/logging.cpp"

	readonly property string metadataHeader: product.cutehmi.conventions.includeDir + "/metadata.hpp"

	readonly property string platformHeader: product.cutehmi.conventions.internalIncludeDir + "/platform.hpp"

	readonly property string qmlPluginHeader: product.cutehmi.conventions.internalSourceDir + "/QMLPlugin.hpp"

	readonly property string qmlPluginSource: product.cutehmi.conventions.internalSourceDir + "/QMLPlugin.cpp"

	readonly property string testLoggingSource: product.cutehmi.conventions.testsDir + "/test_logging.cpp"

	readonly property string testQbs: product.cutehmi.conventions.testsDir + "/Test.qbs"

	readonly property string testsQbs: product.cutehmi.conventions.testsDir + "/tests.qbs"

	readonly property string commonIncludeGuard: product.cutehmi.conventions.functions.includeGuard(project.sourceDirectory, product.cutehmi.skeleton.cpp.commonHeader)

	readonly property string exceptionIncludeGuard: product.cutehmi.conventions.functions.includeGuard(project.sourceDirectory, product.cutehmi.skeleton.cpp.exceptionHeader)

	readonly property string loggingIncludeGuard: product.cutehmi.conventions.functions.includeGuard(project.sourceDirectory, product.cutehmi.skeleton.cpp.loggingHeader)

	readonly property string metadataIncludeGuard: product.cutehmi.conventions.functions.includeGuard(project.sourceDirectory, product.cutehmi.skeleton.cpp.metadataHeader)

	readonly property string platformIncludeGuard: product.cutehmi.conventions.functions.includeGuard(project.sourceDirectory, product.cutehmi.skeleton.cpp.platformHeader)

	readonly property string qmlPluginIncludeGuard: product.cutehmi.conventions.functions.includeGuard(project.sourceDirectory, product.cutehmi.skeleton.cpp.qmlPluginHeader)

	validate: {
		if (!File.exists(product.sourceDirectory + "/README.md"))
			console.warn("File 'README.md' does not exist in '" + product.sourceDirectory + "' directory, please create it (file should contain a description of an extension)")
		if (!File.exists(product.sourceDirectory + "/LICENSE"))
			console.warn("File 'LICENSE' does not exist in '" + product.sourceDirectory + "' directory, please create it (file should contain a text of a license under which extension is distributed)")
	}

	Depends { name: "cutehmi.conventions" }

	Rule {
		multiplex: true

		prepare: {
			// Qbs does not allow for a Rule without commands, so create empty command, if none of the real commands get into `result` array.
			var emptyCmd = new JavaScriptCommand()
			emptyCmd.silent = true;

			var result = [emptyCmd]

			var metadataAvailable = false
			var cutehmiAvailable = false
			var qtCoreAvailable = false
			for (i in product.dependencies) {
				if (product.dependencies[i].name === "Qt.core")
					qtCoreAvailable = true
				if (product.dependencies[i].name === "CuteHMI.2")
					cutehmiAvailable = true
				if (product.dependencies[i].name === "cutehmi.metadata")
					metadataAvailable = true
			}
			if (!qtCoreAvailable) {
				if (product.cutehmi.skeleton.cpp.generateLogging || product.cutehmi.skeleton.cpp.generatePlatform)
					console.warn("C++ extension '" + product.name + "' should depend on 'Qt.core' module, please add appropriate Depends item")
				product.cutehmi.skeleton.cpp.generateLogging = false
				product.cutehmi.skeleton.cpp.generateLoggingTest = false
				product.cutehmi.skeleton.cpp.generateTestQbs = false
				product.cutehmi.skeleton.cpp.generatePlatform = false
			}
			if (!cutehmiAvailable) {
				if (product.cutehmi.skeleton.cpp.generateLogging)
					console.warn("Extension 'CuteHMI.2' not specified for extension '" + product.name + "' with Depends item - this disables generation of logging files, exception and tests")
				product.cutehmi.skeleton.cpp.generateException = false
				product.cutehmi.skeleton.cpp.generateLogging = false
				product.cutehmi.skeleton.cpp.generateLoggingTest = false
				product.cutehmi.skeleton.cpp.generateTestQbs = false
			}
			if (!metadataAvailable) {
				if (product.cutehmi.skeleton.cpp.generateMetadata)
					console.warn("Qbs module 'cutehmi.metadata' not specified for extension '" + product.name + "' with Depends item - this disables generation of metadata files")
				product.cutehmi.skeleton.cpp.generateMetadata = false
			}

			var autogeneratedNotice = "This file has been initially autogenerated by 'cutehmi.skeleton.cpp' Qbs module."

			if (product.cutehmi.skeleton.cpp.generatePlatform && !File.exists(product.cutehmi.skeleton.cpp.platformHeader)) {
				var platformHppCmd = new JavaScriptCommand();
				platformHppCmd.description = "generating " + product.cutehmi.skeleton.cpp.platformHeader
				platformHppCmd.highlight = "codegen";
				platformHppCmd.includeGuard = product.cutehmi.skeleton.cpp.platformIncludeGuard
				platformHppCmd.autogeneratedNotice = autogeneratedNotice
				platformHppCmd.macroPrefix = product.cutehmi.conventions.macroPrefix
				platformHppCmd.sourceCode = function() {
					File.makePath(FileInfo.path(product.cutehmi.skeleton.cpp.platformHeader))
					var f = new TextFile(product.cutehmi.skeleton.cpp.platformHeader, TextFile.WriteOnly)
					try {
						f.writeLine("#ifndef " + includeGuard)
						f.writeLine("#define " + includeGuard)

						f.writeLine("")
						f.writeLine("// " + autogeneratedNotice)

						f.writeLine("")
						f.writeLine("#include <QtGlobal>")

						f.writeLine("")
						f.writeLine("#ifdef " + macroPrefix + "_DYNAMIC")
						f.writeLine("	#ifdef " + macroPrefix + "_BUILD")
						f.writeLine("		// Export symbols to dynamic library.")
						f.writeLine("		#define " + macroPrefix + "_API Q_DECL_EXPORT")
						f.writeLine("		#ifdef " + macroPrefix + "_TESTS")
						f.writeLine("			// Export symbols to dynamic library.")
						f.writeLine("			#define " + macroPrefix + "_PRIVATE Q_DECL_EXPORT")
						f.writeLine("		#else")
						f.writeLine("			#define " + macroPrefix + "_PRIVATE")
						f.writeLine("		#endif")
						f.writeLine("	#else")
						f.writeLine("		// Using symbols from dynamic library.")
						f.writeLine("		#define " + macroPrefix + "_API Q_DECL_IMPORT")
						f.writeLine("		#ifdef " + macroPrefix + "_TESTS")
						f.writeLine("			// Using symbols from dynamic library.")
						f.writeLine("			#define " + macroPrefix + "_PRIVATE Q_DECL_IMPORT")
						f.writeLine("		#else")
						f.writeLine("			#define " + macroPrefix + "_PRIVATE")
						f.writeLine("		#endif")
						f.writeLine("	#endif")
						f.writeLine("#else")
						f.writeLine("	#define " + macroPrefix + "_API")
						f.writeLine("	#define " + macroPrefix + "_PRIVATE")
						f.writeLine("#endif")

						f.writeLine("")
						f.writeLine("#endif")
					} finally {
						f.close()
					}
				}
				result.push(platformHppCmd)
			}

			if (product.cutehmi.skeleton.cpp.generateException && !File.exists(product.cutehmi.skeleton.cpp.exceptionHeader)) {
				var exceptionHppCmd = new JavaScriptCommand();
				exceptionHppCmd.description = "generating " + product.cutehmi.skeleton.cpp.exceptionHeader
				exceptionHppCmd.highlight = "codegen";
				exceptionHppCmd.includeGuard = product.cutehmi.skeleton.cpp.exceptionIncludeGuard
				exceptionHppCmd.autogeneratedNotice = autogeneratedNotice
				exceptionHppCmd.macroPrefix = product.cutehmi.conventions.macroPrefix
				exceptionHppCmd.namespaceArray = product.cutehmi.conventions.namespaceArray
				exceptionHppCmd.sourceCode = function() {
					File.makePath(FileInfo.path(product.cutehmi.skeleton.cpp.exceptionHeader))
					var f = new TextFile(product.cutehmi.skeleton.cpp.exceptionHeader, TextFile.WriteOnly)
					try {
						f.writeLine("#ifndef " + includeGuard)
						f.writeLine("#define " + includeGuard)

						f.writeLine("")
						f.writeLine("// " + autogeneratedNotice)

						f.writeLine("")
						f.writeLine("#include \"internal/platform.hpp\"")
						f.writeLine("")
						f.writeLine("#include <cutehmi/ExceptionMixin.hpp>")

						f.writeLine("")
						for (var level in namespaceArray)
							f.writeLine("namespace " + namespaceArray[level] + " {")

						f.writeLine("")
						f.writeLine("class " + macroPrefix + "_API Exception:")
						f.writeLine("	public ExceptionMixin<Exception>")
						f.writeLine("{")
						f.writeLine("		typedef ExceptionMixin<Exception> Parent;")
						f.writeLine("")
						f.writeLine("	public:")
						f.writeLine("		using Parent::Parent;")
						f.writeLine("};")

						f.writeLine("")
						for (var level in namespaceArray)
							f.writeLine("}")

						f.writeLine("")
						f.writeLine("#endif")
					} finally {
						f.close()
					}
				}
				result.push(exceptionHppCmd)
			}

			if (product.cutehmi.skeleton.cpp.generateMetadata && !File.exists(product.cutehmi.skeleton.cpp.metadataHeader)) {
				var metadataHppCmd = new JavaScriptCommand();
				metadataHppCmd.description = "generating " + product.cutehmi.skeleton.cpp.metadataHeader
				metadataHppCmd.highlight = "codegen";
				metadataHppCmd.includeGuard = product.cutehmi.skeleton.cpp.metadataIncludeGuard
				metadataHppCmd.autogeneratedNotice = autogeneratedNotice
				metadataHppCmd.metadataHppPathPrefix = FileInfo.relativePath(FileInfo.path(product.cutehmi.skeleton.cpp.metadataHeader), product.sourceDirectory)
				metadataHppCmd.sourceCode = function() {
					File.makePath(FileInfo.path(product.cutehmi.skeleton.cpp.metadataHeader))
					var f = new TextFile(product.cutehmi.skeleton.cpp.metadataHeader, TextFile.WriteOnly)
					try {
						f.writeLine("#ifndef " + includeGuard)
						f.writeLine("#define " + includeGuard)

						f.writeLine("")
						f.writeLine("// " + autogeneratedNotice)

						f.writeLine("")
						f.writeLine("#include \"" + metadataHppPathPrefix + "cutehmi.metadata.hpp\"")

						f.writeLine("")
						f.writeLine("#endif")
					} finally {
						f.close()
					}
				}
				result.push(metadataHppCmd)
			}

			if (product.cutehmi.skeleton.cpp.generateCommon && !File.exists(product.cutehmi.skeleton.cpp.commonHeader)) {
				var commonHppCmd = new JavaScriptCommand();
				commonHppCmd.description = "generating " + product.cutehmi.skeleton.cpp.commonHeader
				commonHppCmd.highlight = "codegen";
				commonHppCmd.includeGuard = product.cutehmi.skeleton.cpp.commonIncludeGuard
				commonHppCmd.autogeneratedNotice = autogeneratedNotice
				commonHppCmd.usePlatform = product.cutehmi.skeleton.cpp.generatePlatform
				commonHppCmd.useMetadata = product.cutehmi.skeleton.cpp.generateMetadata
				commonHppCmd.useLogging = product.cutehmi.skeleton.cpp.generateLogging
				commonHppCmd.useCutehmi = cutehmiAvailable
				commonHppCmd.sourceCode = function() {
					File.makePath(FileInfo.path(product.cutehmi.skeleton.cpp.commonHeader))
					var f = new TextFile(product.cutehmi.skeleton.cpp.commonHeader, TextFile.WriteOnly)
					try {
						f.writeLine("#ifndef " + includeGuard)
						f.writeLine("#define " + includeGuard)

						f.writeLine("")
						f.writeLine("// " + autogeneratedNotice)

						f.writeLine("")
						if (usePlatform)
							f.writeLine("#include \"platform.hpp\"")
						if (useMetadata)
							f.writeLine("#include \"../metadata.hpp\"")
						if (useLogging)
							f.writeLine("#include \"../logging.hpp\"")

						f.writeLine("")
						if (useCutehmi) {
							f.writeLine("#include <cutehmi/MPtr.hpp>")
							f.writeLine("#include <cutehmi/macros.hpp>")
						}

						f.writeLine("")
						f.writeLine("#include <QtGlobal>")

						f.writeLine("")
						f.writeLine("#endif")
					} finally {
						f.close()
					}
				}
				result.push(commonHppCmd)
			}

			if (product.cutehmi.skeleton.cpp.generateLogging && !File.exists(product.cutehmi.skeleton.cpp.loggingHeader)) {
				var loggingHppCmd = new JavaScriptCommand();
				loggingHppCmd.description = "generating " + product.cutehmi.skeleton.cpp.loggingHeader
				loggingHppCmd.highlight = "codegen";
				loggingHppCmd.includeGuard = product.cutehmi.skeleton.cpp.loggingIncludeGuard
				loggingHppCmd.autogeneratedNotice = autogeneratedNotice
				loggingHppCmd.macroPrefix = product.cutehmi.conventions.macroPrefix
				loggingHppCmd.namespaceArray = product.cutehmi.conventions.namespaceArray
				loggingHppCmd.loggingCategory = product.cutehmi.conventions.loggingCategory
				loggingHppCmd.sourceCode = function() {
					File.makePath(FileInfo.path(product.cutehmi.skeleton.cpp.loggingHeader))
					var f = new TextFile(product.cutehmi.skeleton.cpp.loggingHeader, TextFile.WriteOnly)
					try {
						f.writeLine("#ifndef " + includeGuard)
						f.writeLine("#define " + includeGuard)

						f.writeLine("")
						f.writeLine("// " + autogeneratedNotice)

						f.writeLine("")
						f.writeLine("#include \"internal/platform.hpp\"")
						f.writeLine("#include <cutehmi/loggingMacros.hpp>")

						f.writeLine("")
						f.writeLine(macroPrefix + "_API Q_DECLARE_LOGGING_CATEGORY(" + loggingCategory + "_loggingCategory)")

						f.writeLine("")
						for (var level in namespaceArray)
							f.writeLine("namespace " + namespaceArray[level] + " {")

						f.writeLine("")
						f.writeLine("inline")
						f.writeLine("const QLoggingCategory & loggingCategory()")
						f.writeLine("{")
						f.writeLine("	return " + loggingCategory + "_loggingCategory();")
						f.writeLine("}")

						f.writeLine("")
						for (var level in namespaceArray)
							f.writeLine("}")

						f.writeLine("")
						f.writeLine("#endif")
					} finally {
						f.close()
					}
				}
				result.push(loggingHppCmd)
			}

			if (product.cutehmi.skeleton.cpp.generateLogging && !File.exists(product.cutehmi.skeleton.cpp.loggingSource)) {
				var loggingCppCmd = new JavaScriptCommand();
				loggingCppCmd.description = "generating " + product.cutehmi.skeleton.cpp.loggingSource
				loggingCppCmd.highlight = "codegen";
				loggingCppCmd.autogeneratedNotice = autogeneratedNotice
				loggingCppCmd.loggingCategory = product.cutehmi.conventions.loggingCategory
				loggingCppCmd.loggingCategoryId = product.name
				loggingCppCmd.macroPrefix = product.cutehmi.conventions.macroPrefix
				loggingCppCmd.useMetadata = product.cutehmi.skeleton.cpp.generateMetadata
				loggingCppCmd.includeDirPrefix = product.cutehmi.conventions.dedicatedSubdir
				loggingCppCmd.sourceCode = function() {
					File.makePath(FileInfo.path(product.cutehmi.skeleton.cpp.loggingSource))
					var f = new TextFile(product.cutehmi.skeleton.cpp.loggingSource, TextFile.WriteOnly)
					try {
						f.writeLine("#include <" + includeDirPrefix + "/logging.hpp>")
						if (useMetadata)
							f.writeLine("#include <" + includeDirPrefix + "/metadata.hpp>")

						f.writeLine("")
						f.writeLine("// " + autogeneratedNotice)

						f.writeLine("")
						if (useMetadata)
							f.writeLine("Q_LOGGING_CATEGORY(" + loggingCategory + "_loggingCategory, " + macroPrefix + "_NAME)")
						else
							f.writeLine("Q_LOGGING_CATEGORY(" + loggingCategory + "_loggingCategory, \"" + loggingCategoryId + "\")")
					} finally {
						f.close()
					}
				}
				result.push(loggingCppCmd)
			}

			if (product.cutehmi.skeleton.cpp.generateLoggingTest && !File.exists(product.cutehmi.skeleton.cpp.testLoggingSource)) {
				var loggingTestCmd = new JavaScriptCommand()
				loggingTestCmd.description = "generating " + product.cutehmi.skeleton.cpp.testLoggingSource
				loggingTestCmd.highlight = "codegen";
				loggingTestCmd.autogeneratedNotice = autogeneratedNotice
				loggingTestCmd.loggingCategoryId = product.name
				loggingTestCmd.namespaceArray = product.cutehmi.conventions.namespaceArray
				loggingTestCmd.namespace = product.cutehmi.conventions.namespace
				loggingTestCmd.includeDirPrefix = product.cutehmi.conventions.dedicatedSubdir
				loggingTestCmd.sourceCode = function() {
					File.makePath(FileInfo.path(product.cutehmi.skeleton.cpp.testLoggingSource))
					var f = new TextFile(product.cutehmi.skeleton.cpp.testLoggingSource, TextFile.WriteOnly)
					try {
						f.writeLine("#include <" + includeDirPrefix + "/logging.hpp>")

						f.writeLine("")
						f.writeLine("#include <QtTest/QtTest>")

						f.writeLine("")
						f.writeLine("// " + autogeneratedNotice)

						f.writeLine("")
						for (var level in namespaceArray)
							f.writeLine("namespace " + namespaceArray[level] + " {")

						f.writeLine("")
						f.writeLine("class test_logging:")
						f.writeLine("	public QObject")
						f.writeLine("{")
						f.writeLine("	Q_OBJECT")
						f.writeLine("")
						f.writeLine("	private slots:")
						f.writeLine("		void loggingCategory();")
						f.writeLine("};")

						f.writeLine("")
						f.writeLine("void test_logging::loggingCategory()")
						f.writeLine("{")
						f.writeLine("	QCOMPARE(" + namespace + "::loggingCategory().categoryName(), \"" + loggingCategoryId + "\");")
						f.writeLine("}")

						f.writeLine("")
						for (var level in namespaceArray)
							f.writeLine("}")

						f.writeLine("")
						f.writeLine("QTEST_MAIN(" + namespace + "::test_logging)")
						f.writeLine("#include \"test_logging.moc\"")
					} finally {
						f.close()
					}
				}
				result.push(loggingTestCmd)
			}

			if (product.cutehmi.skeleton.cpp.generateLoggingTest && !File.exists(product.cutehmi.skeleton.cpp.testsQbs)) {
				var testsQbsCmd = new JavaScriptCommand();
				testsQbsCmd.description = "generating " + product.cutehmi.skeleton.cpp.testsQbs
				testsQbsCmd.highlight = "codegen";
				testsQbsCmd.autogeneratedNotice = autogeneratedNotice
				testsQbsCmd.sourceCode = function() {
					File.makePath(FileInfo.path(product.cutehmi.skeleton.cpp.testsQbs))
					var f = new TextFile(product.cutehmi.skeleton.cpp.testsQbs, TextFile.WriteOnly)
					try {
						f.writeLine("import qbs")

						f.writeLine("")
						f.writeLine("import \"Test.qbs\" as Test")

						f.writeLine("")
						f.writeLine("// " + autogeneratedNotice)

						f.writeLine("")
						f.writeLine("Project {")
						f.writeLine("	Test {")
						f.writeLine("		testName: \"test_logging\"")
						f.writeLine("")
						f.writeLine("		files: [")
						f.writeLine("			\"test_logging.cpp\"")
						f.writeLine("		]")
						f.writeLine("	}")
						f.writeLine("}")
					} finally {
						f.close()
					}
				}
				result.push(testsQbsCmd)
			}

			if (product.cutehmi.skeleton.cpp.generateLoggingTest && !File.exists(product.cutehmi.skeleton.cpp.testQbs)) {
				var testQbsCmd = new JavaScriptCommand();
				testQbsCmd.description = "generating " + product.cutehmi.skeleton.cpp.testQbs
				testQbsCmd.highlight = "codegen";
				testQbsCmd.autogeneratedNotice = autogeneratedNotice
				testQbsCmd.extensionName = product.name
				testQbsCmd.sourceCode = function() {
					File.makePath(FileInfo.path(product.cutehmi.skeleton.cpp.testQbs))
					var f = new TextFile(product.cutehmi.skeleton.cpp.testQbs, TextFile.WriteOnly)
					try {
						f.writeLine("import qbs")

						f.writeLine("")
						f.writeLine("import cutehmi")

						f.writeLine("")
						f.writeLine("// " + autogeneratedNotice)

						f.writeLine("")
						f.writeLine("cutehmi.Test {")
						f.writeLine("	testNamePrefix: parent.parent.name")
						f.writeLine("")
						f.writeLine("	Depends { name: \"" + extensionName + "\" }")
						f.writeLine("}")
					} finally {
						f.close()
					}
				}
				result.push(testQbsCmd)
			}

			if (product.cutehmi.skeleton.cpp.generateQMLPlugin && !File.exists(product.cutehmi.skeleton.cpp.qmlPluginHeader)) {
				var qmlPluginHppCmd = new JavaScriptCommand();
				qmlPluginHppCmd.description = "generating " + product.cutehmi.skeleton.cpp.qmlPluginHeader
				qmlPluginHppCmd.highlight = "codegen";
				qmlPluginHppCmd.includeGuard = product.cutehmi.skeleton.cpp.qmlPluginIncludeGuard
				qmlPluginHppCmd.autogeneratedNotice = autogeneratedNotice
				qmlPluginHppCmd.macroPrefix = product.cutehmi.conventions.macroPrefix
				qmlPluginHppCmd.namespaceArray = product.cutehmi.conventions.namespaceArray
				qmlPluginHppCmd.namespaceArray.push("internal")
				qmlPluginHppCmd.sourceCode = function() {
					File.makePath(FileInfo.path(product.cutehmi.skeleton.cpp.qmlPluginHeader))
					var f = new TextFile(product.cutehmi.skeleton.cpp.qmlPluginHeader, TextFile.WriteOnly)
					try {
						f.writeLine("#ifndef " + includeGuard)
						f.writeLine("#define " + includeGuard)

						f.writeLine("")
						f.writeLine("// " + autogeneratedNotice)

						f.writeLine("")
						f.writeLine("#include <QQmlExtensionPlugin>")

						f.writeLine("")
						for (var level in namespaceArray)
							f.writeLine("namespace " + namespaceArray[level] + " {")

						f.writeLine("")
						f.writeLine("/**")
						f.writeLine(" * QML plugin.")
						f.writeLine(" */")
						f.writeLine("class QMLPlugin:")
						f.writeLine("	public QQmlExtensionPlugin")
						f.writeLine("{")
						f.writeLine("		Q_OBJECT")
						f.writeLine("		Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)")
						f.writeLine("")
						f.writeLine("	public:")
						f.writeLine("		/**")
						f.writeLine("		 * Register QML types.")
						f.writeLine("		 * @param uri URI.")
						f.writeLine("		 */")
						f.writeLine("		void registerTypes(const char * uri) override;")
						f.writeLine("};")

						f.writeLine("")
						for (var level in namespaceArray)
							f.writeLine("}")

						f.writeLine("")
						f.writeLine("#endif")
					} finally {
						f.close()
					}
				}
				result.push(qmlPluginHppCmd)
			}

			if (product.cutehmi.skeleton.cpp.generateQMLPlugin && !File.exists(product.cutehmi.skeleton.cpp.qmlPluginSource)) {
				var qmlPluginCppCmd = new JavaScriptCommand();
				qmlPluginCppCmd.description = "generating " + product.cutehmi.skeleton.cpp.qmlPluginSource
				qmlPluginCppCmd.highlight = "codegen";
				qmlPluginCppCmd.autogeneratedNotice = autogeneratedNotice
				qmlPluginCppCmd.includeDirPrefix = product.cutehmi.conventions.dedicatedSubdir
				qmlPluginCppCmd.uri = product.baseName
				qmlPluginCppCmd.majorVersionMacro = product.cutehmi.conventions.macroPrefix + "_MAJOR"
				qmlPluginCppCmd.namespaceArray = product.cutehmi.conventions.namespaceArray
				qmlPluginCppCmd.namespaceArray.push("internal")
				qmlPluginCppCmd.sourceCode = function() {
					File.makePath(FileInfo.path(product.cutehmi.skeleton.cpp.qmlPluginSource))
					var f = new TextFile(product.cutehmi.skeleton.cpp.qmlPluginSource, TextFile.WriteOnly)
					try {
						f.writeLine("#include \"QMLPlugin.hpp\"")

						f.writeLine("")
						f.writeLine("#include <" + includeDirPrefix + "/internal/common.hpp>")

						f.writeLine("")
						f.writeLine("#include <QtQml>")

						f.writeLine("")
						f.writeLine("// " + autogeneratedNotice)

						f.writeLine("")
						for (var level in namespaceArray)
							f.writeLine("namespace " + namespaceArray[level] + " {")

						f.writeLine("")
						f.writeLine("void QMLPlugin::registerTypes(const char * uri)")
						f.writeLine("{")
						f.writeLine("	Q_ASSERT(uri == QLatin1String(\"" + uri + "\"));")
						f.writeLine("")
						//<qbs-cutehmi.skeleton.cpp-1.workaround target="qmlplugindump" cause="bug">
						f.writeLine("	qmlRegisterType<QObject>(uri, " + majorVersionMacro + ", 0, \"Object\");")
						//</qbs-cutehmi.skeleton.cpp-1.workaround>
						f.writeLine("}")

						f.writeLine("")
						for (var level in namespaceArray)
							f.writeLine("}")
					} finally {
						f.close()
					}
				}
				result.push(qmlPluginCppCmd)
			}


			return result
		}

		outputFileTags: ["cutehmi.skeleton.cpp"]
	}
}

//(c)C: Copyright © 2020, Michał Policht <michal@policht.pl>. All rights reserved.
//(c)C: This file is a part of CuteHMI.
//(c)C: CuteHMI is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//(c)C: CuteHMI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.
//(c)C: You should have received a copy of the GNU Lesser General Public License along with CuteHMI.  If not, see <https://www.gnu.org/licenses/>.
