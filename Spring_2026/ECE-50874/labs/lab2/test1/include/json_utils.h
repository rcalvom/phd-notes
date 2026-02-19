#ifndef JSON_UTILS_H
#define JSON_UTILS_H

#include <json/json.h>

#include <string>

bool parse_json_line(const std::string& line, Json::Value* out, std::string* err);
std::string to_compact_json(const Json::Value& value);

#endif
