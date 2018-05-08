package ch.bubendorf.gsak2gpx

import freemarker.template.*

class SubString : TemplateMethodModelEx {

    @Throws(TemplateModelException::class)
    override fun exec(args: List<*>): TemplateModel {
        if (args.size != 3) {
            throw TemplateModelException("Wrong number of arguments.Must be three")
        }

        return SimpleNumber(
                (args[1] as String).indexOf(args[0] as String))
    }
}
