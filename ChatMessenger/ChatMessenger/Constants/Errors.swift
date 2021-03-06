/*
* Copyright (c) 2016 Magnet Systems, Inc.
* All rights reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License"); you
* may not use this file except in compliance with the License. You
* may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
* implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

import Foundation

public enum MMXHttpError: Int {
    case Ok = 200
    case BadRequest = 400
    case Conflict = 409
    case NotFound = 404
    case ServerError = 500
    case ServerUnavailable = 503
    case ServerTimeout = 504
    case Unauthorized = 401
    case Offline = -1009
}