typedef struct _IO_STATUS_BLOCK {
    NTSTATUS Status;
    ULONG Information;
} IO_STATUS_BLOCK, *PIO_STATUS_BLOCK;

//used ntdll.dll's APIs:
extern "C" NTSTATUS  __stdcall NtUnmapViewOfSection (
		IN HANDLE  ProcessHandle,
		IN PVOID  BaseAddress
		);

extern "C" NTSTATUS __stdcall NtOpenSection (OUT PHANDLE  SectionHandle,IN ACCESS_MASK  DesiredAccess,IN POBJECT_ATTRIBUTES  ObjectAttributes);
		                                 
extern "C" NTSTATUS __stdcall NtMapViewOfSection (
		IN HANDLE  SectionHandle,
		IN HANDLE  ProcessHandle,
		IN OUT PVOID  *BaseAddress,
		IN ULONG  ZeroBits,
		IN ULONG  CommitSize,
		IN OUT PLARGE_INTEGER  SectionOffset,	/* optional */
		IN OUT PULONG  ViewSize,
		IN SECTION_INHERIT  InheritDisposition,
		IN ULONG  AllocationType,
		IN ULONG  Protect
		);

extern "C" VOID __stdcall RtlInitUnicodeString (
		IN OUT PUNICODE_STRING  DestinationString,
		IN PCWSTR  SourceString
		);

extern "C" ULONG __stdcall RtlNtStatusToDosError (
		IN NTSTATUS Status
		);

extern "C" NTSTATUS __stdcall NtClose (
	IN HANDLE	hObject
	);

extern "C" NTSTATUS __stdcall ZwOpenFile(
	OUT PHANDLE phFile,
	IN ACCESS_MASK DesiredAccess,
	IN POBJECT_ATTRIBUTES ObjectAttributes,
	OUT PIO_STATUS_BLOCK pIoStatusBlock,
	IN ULONG ShareMode,
	IN ULONG OpenMode
);

#define NTKERNELAPI DECLSPEC_IMPORT         // wdm

NTKERNELAPI
PPHYSICAL_MEMORY_RANGE
MmGetPhysicalMemoryRanges (
    VOID
    );

