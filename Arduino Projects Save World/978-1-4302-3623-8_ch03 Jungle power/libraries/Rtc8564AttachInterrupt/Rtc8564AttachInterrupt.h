#ifndef Rtc8564AttachInterrupt_h
#define Rtc8564AttachInterrupt_h

#include <inttypes.h>

class Rtc8564AttachInterrupt
{
private:
	void init(void);
	uint8_t _seconds;
	uint8_t _minutes;
	uint8_t _hours;
	uint8_t _days;
	uint8_t _weekdays;
	uint8_t _months;
	uint8_t _years;
	bool	_century;
	
public:
	enum {
		BCD = 0,
		Decimal = 1,
	};
	Rtc8564AttachInterrupt();
  void begin(void);
  void beginWithoutIsValid(void);
  void initDatetime(uint8_t date_time[]);
  bool isInitDatetime(void);
  void sync(uint8_t date_time[],uint8_t size = 7);
  void syncInterrupt(unsigned int mode, unsigned long term);
	bool available(void);
  bool isvalid(void);
  bool isInterrupt(void);
	uint8_t seconds(uint8_t format = Rtc8564AttachInterrupt::BCD) const;
	uint8_t minutes(uint8_t format = Rtc8564AttachInterrupt::BCD) const;
	uint8_t hours(uint8_t format   = Rtc8564AttachInterrupt::BCD) const;
	uint8_t days(uint8_t format    = Rtc8564AttachInterrupt::BCD) const;
	uint8_t weekdays() const;
	uint8_t months(uint8_t format  = Rtc8564AttachInterrupt::BCD) const;
	uint8_t years(uint8_t format   = Rtc8564AttachInterrupt::BCD) const;
	bool century() const;
};

extern Rtc8564AttachInterrupt Rtc;

#endif
