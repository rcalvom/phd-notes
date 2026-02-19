#include "json_utils.h"

#include <json/reader.h>
#include <json/writer.h>

bool parse_json_line(const std::string& line, Json::Value* out, std::string* err) {
  Json::CharReaderBuilder builder;
  builder["collectComments"] = false;
  std::string parse_err;
  std::unique_ptr<Json::CharReader> reader(builder.newCharReader());
  const bool ok = reader->parse(line.data(), line.data() + line.size(), out, &parse_err);
  if (!ok && err != nullptr) {
    *err = parse_err;
  }
  return ok;
}

std::string to_compact_json(const Json::Value& value) {
  Json::StreamWriterBuilder builder;
  builder["indentation"] = "";
  builder["emitUTF8"] = true;
  return Json::writeString(builder, value);
}
