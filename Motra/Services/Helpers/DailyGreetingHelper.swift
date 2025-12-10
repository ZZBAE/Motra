//
//  DailyGreetingHelper.swift
//  Motra
//
//  Created by Jaeeun Byun on 12/10/25.
//

import Foundation

struct DailyGreeting {
    let dateString: String  // "2025년 12월 10일 수요일"
    let message: String     // 요일별 멘트
    
    static func today() -> DailyGreeting {
        let now = Date()
        
        // 날짜 포맷팅 (한국어)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 M월 d일 EEEE"
        let dateString = dateFormatter.string(from: now)
        
        // 요일 가져오기
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now)
        
        // 요일별 멘트
        let message = messageForWeekday(weekday)
        
        return DailyGreeting(dateString: dateString, message: message)
    }
    
    private static func messageForWeekday(_ weekday: Int) -> String {
        // Calendar.weekday: 1 = 일요일, 2 = 월요일, ... 7 = 토요일
        switch weekday {
        case 1: // 일요일
            return "편안한 일요일, 가볍게 몸을 움직여보세요 ☀️"
        case 2: // 월요일
            return "일주일의 시작, 활기차게 달려볼까요? 💪"
        case 3: // 화요일
            return "화이팅 넘치는 화요일이에요! 🔥"
        case 4: // 수요일
            return "벌써 수요일, 오늘도 한 걸음씩! 👟"
        case 5: // 목요일
            return "목요일, 주말이 코앞이에요! 🎯"
        case 6: // 금요일
            return "불금엔 땀 흘리며 스트레스 날려요! 🎉"
        case 7: // 토요일
            return "토요일엔 여유롭게 러닝 어때요? 🌿"
        default:
            return "오늘도 건강한 하루 보내세요! 🏃‍♂️"
        }
    }
}
